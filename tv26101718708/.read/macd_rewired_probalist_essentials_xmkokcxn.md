# MACD Rewired [Probalist Essentials]

- url: https://www.tradingview.com/script/xmkOkCxN-MACD-Rewired-Probalist-Essentials/
- type: indicator
- pine_id: PUB;0d641ffda551483599dc2e39e606196e
- version: 3.0

## Description

MACD Rewired is the canonical Moving Average Convergence Divergence — fast EMA minus slow EMA, smoothed through a signal EMA — rebuilt with a 4-state histogram, regular and hidden divergence detection, and an empirical forward-return distribution on every signal cross.

It's aimed at momentum traders who already know MACD and want a version that earns its place: the histogram tells you not just where price is but whether momentum is building or fading, the divergence labels flag the structural shifts the raw histogram misses, and the probability panel shows what this chart's own history recorded after past crosses.

[b]🟡 WHY THIS VERSION[/b]

The histogram alone doesn't tell you whether a reading above zero is growing or about to roll — this version colour-codes all four states so you can see momentum building vs. fading at a glance, in the right direction. The divergence labels (regular and hidden, both bull and bear) are drawn on confirmed pivots and stay put — no repainting. The probability read is the one I find myself actually using: it doesn't promise an edge, it just tells you what happened after past crosses on the specific chart you're looking at, with the sample size and spread shown honestly. Sane defaults, all alerts fire on bar close, and the heat palette makes the wave read intuitively hot or cold with the momentum.

[b]🟡 HOW IT WORKS[/b]

MACD subtracts a slow EMA from a fast EMA to isolate the gap between short-term and medium-term momentum. A signal EMA smoothed over the MACD line then acts as a trigger — crossovers and crossunders are the classic entry cues. The histogram (MACD minus signal) turns that gap into a visual: rising bars show momentum building, falling bars show it fading, and the zero line separates bullish from bearish territory. Four colours cover the four states.

Divergence detection scans confirmed pivot lows/highs in the histogram (ta.pivotlow / ta.pivothigh) and compares them to the corresponding price pivot lows/highs. A regular bullish divergence is price making a lower low while the histogram makes a higher low — momentum not confirming the new price extreme. A hidden bullish divergence is the opposite structure: price makes a higher low while the histogram makes a lower low, suggesting the underlying trend is intact. Bear logic mirrors this on the highs side.

The probability read records the percentage return i_horizon bars after each confirmed signal cross and stores it in separate bull and bear arrays. Once the minimum sample threshold is met it reports win-rate, median return, and the 16th–84th percentile band — the spread, not just a headline number.

[b]🟡 KEY FEATURES[/b]
[list]
[*]4-state histogram colouring: rising/falling × above/below zero — shows whether momentum is building or fading, not just direction
[*]Regular and hidden divergence on both bull and bear sides, drawn on confirmed pivots — non-repainting
[*]Empirical forward-return distribution: records what happened after past signal crosses on this chart and displays a KDE bell curve
[*]Probability projection cone on the most recent signal bar spanning the 16th–84th percentile band
[*]Separate bull and bear outcome arrays — no dilution from pooling opposite-direction signals
[*]Evidence-gated alerts that fire only when the chart's own history backed follow-through (win rate ≥ 55%, positive median)
[*]Weighted signal dots with per-dot hover tooltips showing the read at fire time and the eventual outcome
[*]Optional HTF MACD line as a faint display-only reference — does not gate signals
[*]Probalist heat wave — the MACD line breathes hot/cold with histogram momentum strength
[/list]

[b]🟡 HOW TO USE[/b]
[list]
[*]Use the histogram colour to gauge momentum quality — a bright gold bar above zero means momentum is building bullish; a dim gold bar means it's fading. Same logic in reverse below zero with blue.
[*]Divergence labels (R Bull Div, H Bull Div, R Bear Div, H Bear Div) mark structural mismatches between price and momentum. Regular divergence hints at exhaustion; hidden divergence hints at continuation — neither is a standalone signal.
[*]Signal crosses are the primary cue: crossover above signal line = bullish bias, crossunder = bearish. Use in the direction of higher-timeframe structure for better results.
[*]Check the probability panel before acting on a cross: if the chart shows n < 20, the read is still gathering. Once populated, the 16th–84th band tells you how wide the distribution of past outcomes was — a narrow band with a high win-rate is a different situation from a wide band.
[*]Enable evidence-gated alerts to be notified only when the chart's own history backed a cross at that win-rate threshold. Noisy charts will rarely fire these; trending charts will fire them more.
[*]Set the HTF line to your bias timeframe (e.g. 4H or Daily when trading 1H). If the HTF MACD is below zero while you get a 1H bull cross, treat it as a countertrend setup — confluence or caution, your call.
[/list]

[b]🟡 PAIRS WELL WITH[/b]

MACD measures momentum but doesn't tell you where price is relative to structure. Pair it with a trend filter — a moving average or a Supertrend — so you can tell whether a bullish cross is with or against the prevailing direction. A volume indicator (relative volume or VWAP deviation) helps confirm whether the cross has conviction behind it; a low-volume cross in the middle of a range is a different read from a high-volume cross off a support level. On higher timeframes, a weekly or daily MACD posture gives context the 1H cross alone can't provide. MACD doesn't handle horizontal S/R — key levels from price action or pivot points help frame where the cross is happening in the market structure.

MACD Rewired gives you the classic momentum tool with the context it was always missing: a histogram that shows whether momentum is building or fading, divergence that flags the structural mismatches, and a probability read that keeps score of what this chart's own history said after past crosses. No predictions — just the evidence, shown honestly.

[i]Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ██████╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗████████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝╚══██╔══╝
// ██████╔╝██████╔╝██║   ██║██████╔╝███████║██║     ██║███████╗   ██║
// ██╔═══╝ ██╔══██╗██║   ██║██╔══██╗██╔══██║██║     ██║╚════██║   ██║
// ██║     ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║███████║   ██║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝

// What it shows: MACD line, signal line, and a 4-state momentum histogram (rising/falling × above/below zero).
// Detects regular and hidden bullish/bearish divergence on confirmed pivots.
// Method: canonical MACD = EMA(fast) − EMA(slow); signal = EMA(macd, sig); hist = macd − signal.
// Divergence is found by comparing histogram pivot lows/highs to price pivot lows/highs over a lookback.
// How to use:
//   • Histogram colour tells you both where you are (above/below zero) and whether momentum is building or fading.
//   • Divergence labels mark potential reversals — confirm with price structure before acting.
//   • The probability read reports what forward returns looked like after past crosses on THIS chart.
//   • Set alerts on signal cross, zero cross, or divergence — all fire on bar close only.
//@version=6
indicator(title = "MACD Rewired [Probalist Essentials]", shorttitle = "MACD [P]", overlay = false, max_labels_count = 500, max_lines_count = 100, max_boxes_count = 300, max_polylines_count = 5)

// ─────────────────────────────────────────────
// § INPUTS — Calculation
// ─────────────────────────────────────────────
var string GRP_CALC = "■ Calculation"
i_src        = input.source(close,  "Source",        group = GRP_CALC, tooltip = "Price series fed into the MACD EMAs. Close is standard; try hl2 for a smoother read.")
i_fast       = input.int(12,  "Fast EMA",             group = GRP_CALC, minval = 1, maxval = 200, tooltip = "Period of the fast EMA. Shorter = more reactive. Default 12 is the classic setting.")
i_slow       = input.int(26,  "Slow EMA",             group = GRP_CALC, minval = 1, maxval = 500, tooltip = "Period of the slow EMA. Must be longer than Fast. Default 26 is the classic setting.")
i_sig        = input.int(9,   "Signal EMA",           group = GRP_CALC, minval = 1, maxval = 100, tooltip = "Period of the signal line EMA smoothed over the MACD line. Default 9 is standard.")

// ─────────────────────────────────────────────
// § INPUTS — Divergence
// ─────────────────────────────────────────────
var string GRP_DIV = "■ Divergence"
i_divOn      = input.bool(true,  "Show Divergence",   group = GRP_DIV, tooltip = "Toggle regular and hidden divergence labels on or off.")
i_pivLen     = input.int(5,   "Pivot Lookback",       group = GRP_DIV, minval = 2, maxval = 20, tooltip = "Bars each side to confirm a pivot high or low in the histogram. Larger = fewer but cleaner pivots.")
i_divLook    = input.int(60,  "Divergence Search",   group = GRP_DIV, minval = 10, maxval = 200, tooltip = "How many bars back to scan for the prior pivot to compare. Wider catches more, but risks false positives on ranging markets.")

// ─────────────────────────────────────────────
// § INPUTS — Visuals
// ─────────────────────────────────────────────
var string GRP_VIS = "■ Visuals"
i_showHist   = input.bool(true,  "Show Histogram",    group = GRP_VIS, tooltip = "Show the 4-state colour-coded histogram bars behind the wave.")
i_showSignal = input.bool(true,  "Show Signal Line",  group = GRP_VIS, tooltip = "Plot the signal EMA line on the pane.")

// ─────────────────────────────────────────────
// § INPUTS — Probalist Theme
// ─────────────────────────────────────────────
var string GRP_THEME = "■ Probalist Theme"
i_col_hot    = input.color(color.rgb(249, 115, 22),   "Wave hot (bullish end)",   group = GRP_THEME, tooltip = "Colour at the hot (bullish) end of the MACD wave heat ramp.")
i_col_cold   = input.color(color.rgb(37, 99, 235), "Wave cold (bearish end)",  group = GRP_THEME, tooltip = "Colour at the cold (bearish) end of the MACD wave heat ramp.")
i_dist_gold  = input.color(color.rgb(224, 168, 0),  "Gold accent (bullish)",    group = GRP_THEME, tooltip = "Accent colour for bullish structural elements: signal dots, divergence labels, distribution warm side.")
i_dist_cold  = input.color(color.rgb(50, 160, 255), "Blue accent (bearish)",    group = GRP_THEME, tooltip = "Accent colour for bearish structural elements: signal dots, divergence labels, distribution cold side.")
i_glow       = input.bool(true,  "Glow Effect",                                  group = GRP_THEME, tooltip = "Stacks a soft halo around the MACD wave. Turn off for a clean minimal look.")

// ─────────────────────────────────────────────
// § INPUTS — Higher Timeframe (display only)
// ─────────────────────────────────────────────
var string GRP_HTF = "■ Higher Timeframe"
i_htfOn      = input.bool(false, "Show HTF MACD line", group = GRP_HTF, tooltip = "Display the MACD line from a higher timeframe as a faint reference. Display only — does not gate signals.")
i_htfTf      = input.timeframe("D", "HTF Timeframe",   group = GRP_HTF, tooltip = "Which higher timeframe to show. Default daily.")

// ─────────────────────────────────────────────
// § INPUTS — Probability Read
// ─────────────────────────────────────────────
var string GRP_PROB = "■ Probability Read"
i_probOn     = input.bool(true,  "Probability Read (master)",   group = GRP_PROB, tooltip = "Track forward returns after each signal cross on this chart and show a distribution. What happened after past signals here — description, not prediction.")
i_horizon    = input.int(10,  "Horizon (bars)",               group = GRP_PROB, minval = 1, maxval = 100, tooltip = "How many bars forward to measure the return after a signal cross. Larger = slower to gather samples.")
i_maxSamp    = input.int(200, "Max Samples",                  group = GRP_PROB, minval = 50, maxval = 500, tooltip = "Maximum stored past outcomes. Oldest are dropped once the cap is reached.")
i_minSamp    = input.int(20,  "Min Samples (show stats)",     group = GRP_PROB, minval = 5, maxval = 50, tooltip = "Minimum confirmed outcomes required before showing percentages. Below this prints 'gathering'.")
i_recentN    = input.int(60,  "Recent Window (outcomes)",      group = GRP_PROB, minval = 15, maxval = 100, tooltip = "How many of the most recent outcomes per direction form the RECENT FORM read. Markets move in regimes — the recent window shows whether the signal works NOW, not averaged over years.")
i_evid       = input.string("80%", "Evidence Strictness (Wilson)", group = GRP_PROB, options = ["80%", "90%", "95%"], tooltip = "Confidence level for the Wilson evidence test behind the backed verdict. 80% = more sensitive (edge shows sooner), 95% = strictest.")
float zEv    = i_evid == "95%" ? 1.960 : i_evid == "90%" ? 1.645 : 1.282
i_coneOn     = input.bool(true,  "↳ Projection Cone",      group = GRP_PROB, tooltip = "Draw a forward projection box on the most recent signal bar spanning the 16th–84th percentile band of past outcomes.")
i_distOn     = input.bool(true,  "↳ Distribution Panel (bell curve)",   group = GRP_PROB, tooltip = "Draw a kernel-smoothed bell curve of past forward returns to the right of the last bar.")
i_readoutOn  = input.bool(true,  "↳ Readout panel",           group = GRP_PROB, tooltip = "The chart-anchored info block bottom right (state, per-direction stats, edge clock, Read). Hidden when the master is off.")

// ─────────────────────────────────────────────
// § INPUTS — Alerts
// ─────────────────────────────────────────────
var string GRP_ALERT = "■ Alerts"
i_alertCross = input.bool(true,  "Alert: Signal Cross",       group = GRP_ALERT, tooltip = "Fire an alert when MACD crosses the signal line (bar close).")
i_alertZero  = input.bool(true,  "Alert: Zero Cross",         group = GRP_ALERT, tooltip = "Fire an alert when MACD crosses the zero line (bar close).")
i_alertDiv   = input.bool(true,  "Alert: Divergence",         group = GRP_ALERT, tooltip = "Fire an alert when a regular or hidden divergence is detected (bar close).")

// ─────────────────────────────────────────────
// § PROBALIST HEAT  (official colour engine)
// ─────────────────────────────────────────────
normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

// Probalist VIBRANT ramp: strong blue → cyan → light blue → mint (neutral) →
// yellow → amber → orange. col_cold/col_hot are the picker extremes.
heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245, 158, 11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251, 191, 36), color.rgb(245, 158, 11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167, 243, 208), color.rgb(251, 191, 36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56, 189, 248), color.rgb(167, 243, 208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(6, 182, 212), color.rgb(56, 189, 248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(6, 182, 212))
    color.new(col, transp)

// ─────────────────────────────────────────────
// § MACD CORE CALCULATION
// ─────────────────────────────────────────────
float emaFast  = ta.ema(i_src, i_fast)
float emaSlow  = ta.ema(i_src, i_slow)
float macdLine = emaFast - emaSlow
float sigLine  = ta.ema(macdLine, i_sig)
float hist     = macdLine - sigLine

// Heat score: normalise MACD-hist to ±100 using a rolling stdev
float histStd   = ta.stdev(hist, 50)
float histScore = histStd != 0.0 ? math.max(-100.0, math.min(100.0, hist / histStd * 40.0)) : 0.0
float heatPos   = normScore(histScore)
color cMain     = heatCol(heatPos, 0, i_col_hot, i_col_cold)

// ─────────────────────────────────────────────
// § 4-STATE HISTOGRAM COLOURING (killer extra)
// Rising above zero: bright gold; Falling above zero: dim gold
// Rising below zero: dim blue;  Falling below zero: bright blue
// ─────────────────────────────────────────────
bool  histRising  = hist > hist[1]
bool  histAbove   = hist >= 0.0
color c4state = histAbove and histRising ? color.new(i_dist_gold, 10) : histAbove and not histRising ? color.new(i_dist_gold, 52) : not histAbove and histRising ? color.new(i_dist_cold, 52) : color.new(i_dist_cold, 10)

// ─────────────────────────────────────────────
// § HTF MACD (display only)
// ─────────────────────────────────────────────
float htfMacd = i_htfOn ? request.security(syminfo.tickerid, i_htfTf, macdLine[1], lookahead = barmerge.lookahead_off) : na

// ─────────────────────────────────────────────
// § SIGNAL CROSS DETECTION
// ─────────────────────────────────────────────
bool crossUp   = ta.crossover(macdLine, sigLine)
bool crossDn   = ta.crossunder(macdLine, sigLine)
bool zeroCrossUp = ta.crossover(macdLine, 0.0)
bool zeroCrossDn = ta.crossunder(macdLine, 0.0)

// ─────────────────────────────────────────────
// § DIVERGENCE DETECTION (regular + hidden)
// Uses confirmed histogram pivot highs/lows vs price pivot highs/lows
// ─────────────────────────────────────────────
int pl = i_pivLen

// Pivot lows and highs in histogram
float histPivLo = ta.pivotlow(hist,  pl, pl)
float histPivHi = ta.pivothigh(hist, pl, pl)
// Pivot lows and highs in price (low / high)
float pricePivLo = ta.pivotlow(low,  pl, pl)
float pricePivHi = ta.pivothigh(high, pl, pl)

// Track last two histogram pivot lows with their bar indices and price pivot lows
var float hPL1 = na
var float hPL2 = na
var int   hPLb1 = na
var int   hPLb2 = na
var float pPL1 = na
var float pPL2 = na

var float hPH1 = na
var float hPH2 = na
var int   hPHb1 = na
var int   hPHb2 = na
var float pPH1 = na
var float pPH2 = na

if not na(histPivLo)
    hPL2  := hPL1
    hPLb2 := hPLb1
    pPL2  := pPL1
    hPL1  := histPivLo
    hPLb1 := bar_index - pl
    pPL1  := low[pl]

if not na(histPivHi)
    hPH2  := hPH1
    hPHb2 := hPHb1
    pPH2  := pPH1
    hPH1  := histPivHi
    hPHb1 := bar_index - pl
    pPH1  := high[pl]

// Divergence conditions (evaluated pl bars after the pivot, i.e. when pivot is confirmed)
bool regBullDiv  = false
bool regBearDiv  = false
bool hidBullDiv  = false
bool hidBearDiv  = false

if i_divOn and not na(histPivLo) and not na(hPL1) and not na(hPL2) and not na(pPL1) and not na(pPL2)
    int gap = hPLb1 - hPLb2
    if gap > 0 and gap <= i_divLook
        // Regular bull: price makes lower low, histogram makes higher low
        if pPL1 < pPL2 and hPL1 > hPL2
            regBullDiv := true
        // Hidden bull: price makes higher low, histogram makes lower low
        if pPL1 > pPL2 and hPL1 < hPL2
            hidBullDiv := true

if i_divOn and not na(histPivHi) and not na(hPH1) and not na(hPH2) and not na(pPH1) and not na(pPH2)
    int gap = hPHb1 - hPHb2
    if gap > 0 and gap <= i_divLook
        // Regular bear: price makes higher high, histogram makes lower high
        if pPH1 > pPH2 and hPH1 < hPH2
            regBearDiv := true
        // Hidden bear: price makes lower high, histogram makes higher high
        if pPH1 < pPH2 and hPH1 > hPH2
            hidBearDiv := true

bool anyBullDiv = regBullDiv or hidBullDiv
bool anyBearDiv = regBearDiv or hidBearDiv

// ─────────────────────────────────────────────
// § PROBABILITY READ — outcome tracking
// ─────────────────────────────────────────────
// Primary signal = MACD/signal cross (crossUp = bullish, crossDn = bearish)
// Returns are measured horizon bars forward, in the signal's direction.

var array<float> probArrBull = array.new_float(0)
var array<float> probArrBear = array.new_float(0)

// Check if a signal fired horizon bars ago (confirmed, non-repainting)
bool pastBull = crossUp[i_horizon]
bool pastBear = crossDn[i_horizon]

if barstate.isconfirmed and pastBull
    float ret = (close - close[i_horizon]) / close[i_horizon] * 100.0
    array.push(probArrBull, ret)
    if array.size(probArrBull) > i_maxSamp
        array.shift(probArrBull)

if barstate.isconfirmed and pastBear
    float ret = -(close - close[i_horizon]) / close[i_horizon] * 100.0
    array.push(probArrBear, ret)
    if array.size(probArrBear) > i_maxSamp
        array.shift(probArrBear)

// Stats helper
calcStats(array<float> arr) =>
    int   n       = array.size(arr)
    float med     = n > 0 ? array.median(arr)                               : na
    float p16     = n > 0 ? array.percentile_nearest_rank(arr, 16)          : na
    float p84     = n > 0 ? array.percentile_nearest_rank(arr, 84)          : na
    float wins    = 0.0
    if n > 0
        for i = 0 to n - 1
            if array.get(arr, i) > 0.0
                wins += 1.0
    float wr      = n > 0 ? wins / n * 100.0 : na
    float avg     = n > 0 ? array.avg(arr)    : na
    float sd      = n > 0 ? array.stdev(arr)  : na
    [n, med, p16, p84, wr, avg, sd]

[bN, bMed, bP16, bP84, bWR, bAvg, bSd] = calcStats(probArrBull)
[rN, rMed, rP16, rP84, rWR, rAvg, rSd] = calcStats(probArrBear)

// ── RECENT FORM + WILSON + EDGE CLOCK (the regime layer)
calcRecent(array<float> arr, int k) =>
    int n = array.size(arr)
    int m = math.min(k, n)
    bool has = m >= 15
    float med = na
    float wr  = na
    if has
        array<float> sl = array.slice(arr, n - m, n)
        med := array.median(sl)
        int wins = 0
        for i = 0 to m - 1
            if array.get(sl, i) > 0
                wins += 1
        wr := wins / m * 100.0
    [m, has, med, wr]

[rbN, rbHas, rbMed, rbWr] = calcRecent(probArrBull, i_recentN)
[rdN, rdHas, rdMed, rdWr] = calcRecent(probArrBear, i_recentN)

wilsonLB(float wrPct, int n) =>
    float lb = na
    if n > 0 and not na(wrPct)
        float p   = wrPct / 100.0
        float z   = zEv
        float den = 1.0 + z * z / n
        float ctr = p + z * z / (2.0 * n)
        float mrg = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))
        lb := (ctr - mrg) / den * 100.0
    lb

bool bullBackedLong   = bN >= i_minSamp and wilsonLB(bWR, bN) > 50.0 and bMed > 0
bool bearBackedLong   = rN >= i_minSamp and wilsonLB(rWR, rN) > 50.0 and rMed > 0
bool bullBackedRecent = rbHas and wilsonLB(rbWr, rbN) > 50.0 and rbMed > 0
bool bearBackedRecent = rdHas and wilsonLB(rdWr, rdN) > 50.0 and rdMed > 0
// LEAN: a building edge — point estimate ≥ 55% but the Wilson bar not yet cleared.
bool bullLeanRecent = rbHas and not bullBackedRecent and rbWr >= 55.0 and rbMed > 0
bool bearLeanRecent = rdHas and not bearBackedRecent and rdWr >= 55.0 and rdMed > 0

var int lastEdgeBullT = na
var int lastEdgeBearT = na
if barstate.isconfirmed and bullBackedRecent
    lastEdgeBullT := time
if barstate.isconfirmed and bearBackedRecent
    lastEdgeBearT := time
agoTxt(int t) =>
    string s = "—"
    if not na(t)
        float dh = (time - t) / 3600000.0
        s := dh < 1 ? "now" : dh < 48 ? str.tostring(math.round(dh, 0)) + "h ago" : str.tostring(math.round(dh / 24.0, 0)) + "d ago"
    s

// Which direction was most recent? (+ the bar it fired on, for the Read row age)
var bool lastSigBull = true
var int  lastSigBar  = na
if crossUp and barstate.isconfirmed
    lastSigBull := true
    lastSigBar  := bar_index
if crossDn and barstate.isconfirmed
    lastSigBull := false
    lastSigBar  := bar_index

// Active-direction aliases
int   probN    = lastSigBull ? bN    : rN
float probMed  = lastSigBull ? bMed  : rMed
float probP16  = lastSigBull ? bP16  : rP16
float probP84  = lastSigBull ? bP84  : rP84
float winRate  = lastSigBull ? bWR   : rWR
bool  recBackedAct  = lastSigBull ? bullBackedRecent : bearBackedRecent
bool  longBackedAct = lastSigBull ? bullBackedLong   : bearBackedLong
float recWrAct      = lastSigBull ? rbWr : rdWr
int   recNAct       = lastSigBull ? rbN  : rdN
bool  recHasAct     = lastSigBull ? rbHas : rdHas
bool  leanAct       = lastSigBull ? bullLeanRecent : bearLeanRecent
float probAvg  = lastSigBull ? bAvg  : rAvg
float probSd   = lastSigBull ? bSd   : rSd
bool  hasStats = i_probOn and probN >= i_minSamp

// Evidence gate (for alerts)
bool evBacked  = recBackedAct

// ─────────────────────────────────────────────
// § SIGNAL DOT ARRAYS (weighted labels + tooltips)
// ─────────────────────────────────────────────
var array<label>  dotLabels   = array.new<label>(0)
var array<int>    dotBars     = array.new_int(0)
var array<string> dotBaseTips = array.new_string(0)
var array<bool>   dotIsBull   = array.new_bool(0)

int   MAX_DOTS = 400

// Strength: normalise hist depth vs rolling stdev at signal bar
float signalStrength = histStd != 0.0 ? math.abs(hist) / histStd : 0.0

// Dot tier
string dotStyle = label.style_none
float dotStrCapture = signalStrength

dotSize(float str) =>
    str >= 0.9 ? size.huge : str >= 0.4 ? size.large : size.normal
dotTransp(float str) =>
    str >= 0.9 ? 0 : str >= 0.4 ? 12 : 28

// Outcome updater — runs on the COMPLETION BAR of a signal (exactly i_horizon bars
// after it fired), so the only historical offset used is i_horizon — bounded and
// buffer-safe. Looking up close[bar_index - dotBar] for old dots blows past Pine's
// historical buffer (~2k) and re-annotates every tooltip on every tick.
updateOutcomeTips() =>
    if barstate.isconfirmed and (pastBull or pastBear) and array.size(dotBars) > 0
        float outRet = pastBull ? (close - close[i_horizon]) / close[i_horizon] * 100.0 : -(close - close[i_horizon]) / close[i_horizon] * 100.0
        if not na(outRet)
            int sz = array.size(dotBars)
            for i = 0 to sz - 1
                if array.get(dotBars, i) == bar_index - i_horizon
                    label.set_tooltip(array.get(dotLabels, i), array.get(dotBaseTips, i) + "\nOutcome after " + str.tostring(i_horizon) + "b: " + (outRet >= 0 ? "+" : "") + str.tostring(math.round(outRet, 2)) + "% (in signal direction)")
                    break

// Fire signal dots (confirmed, on the signal bar)
bool fireBull = barstate.isconfirmed and crossUp
bool fireBear = barstate.isconfirmed and crossDn
// Label window: recent signals get tooltip-labels, older ones the plain circle layer.
bool inLblWin = bar_index > last_bar_index - 2000

// Dot lanes — ta.* hoisted to global scope (rule 7: never call ta.* conditionally).
float dotLaneBull = -math.abs(nz(ta.lowest(hist, 50), 1.0)) * 1.1
float dotLaneBear = math.abs(nz(ta.highest(hist, 50), 1.0)) * 1.1

if (fireBull or fireBear) and inLblWin
    bool   isBull  = fireBull
    color  dc      = isBull ? i_dist_gold : i_dist_cold
    float  str1    = dotStrCapture
    string ds      = dotSize(str1)
    int    dtr     = dotTransp(str1)
    string tier    = str1 >= 0.9 ? "strong" : str1 >= 0.4 ? "medium" : "shallow"
    string dirTxt  = isBull ? "Bull cross" : "Bear cross"
    string statVerdict = recBackedAct and longBackedAct ? "\n→ recent + long-run back follow-through" : recBackedAct ? "\n→ recent form backs it — long-run mixed" : leanAct ? "\n→ recent form leans this way — building, not yet evidence" : longBackedAct ? "\n→ long-run backed, recent form cooled" : "\n→ no edge in history here — reads as noise"
    string statTip = (hasStats ? ("recent " + (recHasAct ? str.tostring(math.round(recWrAct, 0)) + "% ↑ (last " + str.tostring(recNAct) + ")" : "n<15") + " · long-run " + str.tostring(math.round(winRate, 0)) + "% ↑ · med " + str.tostring(math.round(probMed, 2)) + "% · n=" + str.tostring(probN)) : ("history still gathering (n=" + str.tostring(probN) + ")")) + statVerdict
    string baseTip = dirTxt + " · excursion " + tier + "\nRead at fire: " + statTip
    string shownTip = baseTip + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…"
    string dotGl   = recBackedAct ? "●" : leanAct or longBackedAct or (hasStats and winRate > 47.0 and probMed > 0) ? "◐" : "○"
    label  lbl     = label.new(bar_index, hist, dotGl, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(dc, dtr), size = ds, tooltip = shownTip)
    label.set_y(lbl, isBull ? dotLaneBull : dotLaneBear)
    array.push(dotLabels, lbl)
    array.push(dotBars, bar_index)
    array.push(dotBaseTips, baseTip)
    array.push(dotIsBull, isBull)
    if array.size(dotLabels) > MAX_DOTS
        label.delete(array.shift(dotLabels))
        array.shift(dotBars)
        array.shift(dotBaseTips)
        array.shift(dotIsBull)

// Write completed outcomes into dot tooltips — every confirmed bar (self-gated inside).
updateOutcomeTips()

// Background circle plots for all history (no label limit)
float bullDotY = fireBull ? -math.abs(nz(ta.lowest(hist, 50), 1)) * 1.1 : na
float bearDotY = fireBear ? math.abs(nz(ta.highest(hist, 50), 1)) * 1.1 : na

// ─────────────────────────────────────────────
// § DIVERGENCE LABELS
// ─────────────────────────────────────────────
color divGoldDim = color.from_gradient(0.45, 0.0, 1.0, color.rgb(110, 110, 110), i_dist_gold)
color divColdDim = color.from_gradient(0.45, 0.0, 1.0, color.rgb(110, 110, 110), i_dist_cold)
// Label nudge proportional to the recent histogram amplitude (MACD has no fixed scale).
float divOff = math.max(math.abs(dotLaneBull), math.abs(dotLaneBear)) * 0.12

if regBullDiv
    label.new(hPLb1, hPL1 - divOff, "R▲", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(i_dist_gold, 20), textcolor = color.white, style = label.style_label_up, size = size.small)
if hidBullDiv
    label.new(hPLb1, hPL1 - divOff, "H▲", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(divGoldDim, 20), textcolor = color.white, style = label.style_label_up, size = size.small)
if regBearDiv
    label.new(hPHb1, hPH1 + divOff, "R▼", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(i_dist_cold, 20), textcolor = color.white, style = label.style_label_down, size = size.small)
if hidBearDiv
    label.new(hPHb1, hPH1 + divOff, "H▼", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(divColdDim, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

// ─────────────────────────────────────────────
// § PLOTS — Histogram
// ─────────────────────────────────────────────
plot(i_showHist ? hist : na, "Histogram", color = c4state, style = plot.style_columns, linewidth = 1)

// Background signal circles (full history, no label cap)
plot(fireBull and not inLblWin ? hist : na, "Bull Dot BG", color = color.new(i_dist_gold, 55), style = plot.style_circles, linewidth = 2)
plot(fireBear and not inLblWin ? hist : na, "Bear Dot BG", color = color.new(i_dist_cold, 55), style = plot.style_circles, linewidth = 2)

// ─────────────────────────────────────────────
// § PLOTS — MACD Wave (gradient fill)
// ─────────────────────────────────────────────
pMacd = plot(macdLine, "MACD", color = cMain, linewidth = 2)
pZero = plot(0.0, "Zero", color = color.new(color.gray, 75), linewidth = 1)
fill(pMacd, pZero, top_value = macdLine, bottom_value = 0.0, top_color = color.new(cMain, 25), bottom_color = color.new(cMain, 92))

// ─────────────────────────────────────────────
// § PLOTS — Signal line
// ─────────────────────────────────────────────
plot(i_showSignal ? sigLine : na, "Signal", color = color.new(color.white, 45), linewidth = 1)

// ─────────────────────────────────────────────
// § PLOTS — HTF reference (display only)
// ─────────────────────────────────────────────
plot(i_htfOn ? htfMacd : na, "HTF MACD", color = color.new(color.white, 65), linewidth = 3)

// ─────────────────────────────────────────────
// § GLOW (H1) — 3-layer halo around the MACD wave
// ─────────────────────────────────────────────
pGlow1 = plot(i_glow ? macdLine + (macdLine >= 0.0 ? 1 : -1) * math.abs(macdLine) * 0.008 : na, "Glow1", color = na, display = display.none)
pGlow2 = plot(i_glow ? macdLine + (macdLine >= 0.0 ? 1 : -1) * math.abs(macdLine) * 0.018 : na, "Glow2", color = na, display = display.none)
pGlow3 = plot(i_glow ? macdLine + (macdLine >= 0.0 ? 1 : -1) * math.abs(macdLine) * 0.032 : na, "Glow3", color = na, display = display.none)
fill(pMacd,  pGlow1, color = i_glow ? color.new(cMain, 65) : na)
fill(pGlow1, pGlow2, color = i_glow ? color.new(cMain, 80) : na)
fill(pGlow2, pGlow3, color = i_glow ? color.new(cMain, 90) : na)

// ─────────────────────────────────────────────
// § HLINES
// ─────────────────────────────────────────────
hline(0.0, "Zero Line", color = color.new(color.gray, 60), linestyle = hline.style_dashed, linewidth = 1)

// ─────────────────────────────────────────────
// § PROBABILITY READ — Projection Cone
float coneRefRange = nz(ta.highest(macdLine, 100) - ta.lowest(macdLine, 100), 1.0)
// ─────────────────────────────────────────────
var box  coneBox     = na
var int  coneBar     = na
var bool coneIsBull  = true
var float coneEntry  = na

// On a new confirmed signal, register the cone anchor
var float coneAnchor = na
if barstate.isconfirmed and (crossUp or crossDn)
    coneBar    := bar_index
    coneIsBull := crossUp
    coneEntry  := close
    coneAnchor := macdLine

// Live projected close for "pending" display
float liveReturn = not na(coneEntry) and coneEntry != 0.0 ? (close - coneEntry) / coneEntry * 100.0 : na
float liveReturnSigned = not na(liveReturn) ? (coneIsBull ? liveReturn : -liveReturn) : na
bool  inHorizon  = not na(coneBar) and (bar_index - coneBar) <= i_horizon

var line  coneMedLn = na
var label coneMedLb = na
if barstate.islast and i_probOn and i_coneOn and hasStats and not na(coneBar) and not na(coneAnchor)
    box.delete(coneBox)
    line.delete(coneMedLn)
    label.delete(coneMedLb)
    // Anchored at the MACD value where the signal fired; the 16th–84th percentile band
    // of past outcomes mapped onto the pane scale (1% return = 1% of the recent range).
    float paneRange = coneRefRange
    float coneTopY  = coneAnchor + probP84 / 100.0 * paneRange
    float coneBotY  = coneAnchor + probP16 / 100.0 * paneRange
    float coneMidY  = coneAnchor + probMed / 100.0 * paneRange
    color coneCol   = coneIsBull ? i_dist_gold : i_dist_cold
    coneBox   := box.new(coneBar, coneTopY, coneBar + i_horizon, coneBotY, border_color = color.new(coneCol, 50), bgcolor = color.new(coneCol, 82), border_width = 1)
    coneMedLn := line.new(coneBar, coneMidY, coneBar + i_horizon, coneMidY, color = color.new(coneCol, 30), width = 1, style = line.style_dashed)
    coneMedLb := label.new(coneBar + i_horizon, coneMidY, "med " + str.tostring(math.round(probMed, 2)) + "%", color = color.new(color.black, 80), textcolor = color.new(#e0a800, 20), style = label.style_label_left, size = size.tiny)

// ─────────────────────────────────────────────
// § PROBABILITY READ — Distribution Panel (KDE bell curve)
// ta.* must run every bar — calling it inside the islast block returns na.
float panelRefHi = ta.highest(macdLine, 80)
float panelRefLo = ta.lowest(macdLine, 80)
// ─────────────────────────────────────────────
var array<box>      kdBoxes  = array.new<box>(0)
var polyline        kdPoly   = na
var label           kdMedLbl = na
var label           kdZeroLbl = na
var label           kdLiveLbl = na
var line            kdMedLine = na
var line            kdZeroLine = na
var line            kdLiveLine = na
var label           kdGatherLbl = na

if barstate.islast and i_probOn and i_distOn
    // Clean up previous
    if array.size(kdBoxes) > 0
        for i = 0 to array.size(kdBoxes) - 1
            box.delete(array.get(kdBoxes, i))
    array.clear(kdBoxes)
    polyline.delete(kdPoly)
    label.delete(kdMedLbl)
    label.delete(kdZeroLbl)
    label.delete(kdLiveLbl)
    line.delete(kdMedLine)
    line.delete(kdZeroLine)
    line.delete(kdLiveLine)
    label.delete(kdGatherLbl)

    // Use active-direction array
    array<float> activeArr = lastSigBull ? probArrBull : probArrBear
    int pN = array.size(activeArr)

    // Pane positioning (panelRefHi/Lo computed unconditionally at global scope — rule 7)
    float recentHi = panelRefHi
    float recentLo = panelRefLo
    float paneH    = nz(recentHi - recentLo, 1.0)
    float panelH   = paneH * 0.45
    float panelBot = recentHi - panelH * 0.05
    float panelTop = panelBot + panelH
    int   panelX0  = bar_index + i_horizon + 6
    int   NSLICE   = 40

    if pN < i_minSamp
        kdGatherLbl := label.new(panelX0 + NSLICE / 2, (panelBot + panelTop) / 2.0, "gathering\nn=" + str.tostring(pN), style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(color.gray, 40), size = size.small)
    else
        // Domain
        float halfBand = math.max((probP84 - probP16) / 2.0, 0.01)
        float domCtr   = probMed
        float domLo    = domCtr - 2.5 * halfBand
        float domHi    = domCtr + 2.5 * halfBand
        float domW     = domHi - domLo
        float bw       = math.max(1.06 * nz(probSd, halfBand) * math.pow(pN, -0.2), domW / 40.0)

        // KDE densities
        array<float> densities = array.new_float(NSLICE, 0.0)
        float maxDens = 0.0
        for s = 0 to NSLICE - 1
            float cx = domLo + (s + 0.5) / NSLICE * domW
            float d  = 0.0
            for j = 0 to pN - 1
                float diff = (cx - array.get(activeArr, j)) / bw
                d += math.exp(-0.5 * diff * diff)
            array.set(densities, s, d)
            if d > maxDens
                maxDens := d

        // Gaussian overlay points
        array<chart.point> gPoints = array.new<chart.point>(0)
        float gAvg = probAvg
        float gSd  = math.max(nz(probSd, halfBand), 0.0001)
        float pdfNorm = 0.0
        for s = 0 to NSLICE - 1
            float cx  = domLo + (s + 0.5) / NSLICE * domW
            float pdf = math.exp(-0.5 * math.pow((cx - gAvg) / gSd, 2.0))
            if pdf > pdfNorm
                pdfNorm := pdf

        for s = 0 to NSLICE - 1
            float cx  = domLo + (s + 0.5) / NSLICE * domW
            float pdf = math.exp(-0.5 * math.pow((cx - gAvg) / gSd, 2.0))
            float gNorm = pdfNorm > 0.0 ? pdf / pdfNorm : 0.0
            float gY  = panelBot + gNorm * panelH
            array.push(gPoints, chart.point.from_index(panelX0 + s, gY))

        kdPoly := polyline.new(gPoints, curved = true, line_color = color.new(color.white, 45), line_width = 1)

        // Slice boxes (3-tier vertical fade)
        for s = 0 to NSLICE - 1
            float dens = maxDens > 0.0 ? array.get(densities, s) / maxDens : 0.0
            if dens > 0.02
                float colPos = (s + 0.5) / NSLICE
                color sc = heatCol(colPos, 0, i_dist_gold, i_dist_cold)
                float sliceH = dens * panelH
                float s0 = panelBot
                float s3 = panelBot + sliceH
                float s1 = s0 + sliceH * 0.30
                float s2 = s0 + sliceH * 0.62
                int bx = panelX0 + s
                box b1 = box.new(bx, s3, bx + 1, s2, border_color = na, bgcolor = color.new(sc, 28))
                box b2 = box.new(bx, s2, bx + 1, s1, border_color = na, bgcolor = color.new(sc, 55))
                box b3 = box.new(bx, s1, bx + 1, s0, border_color = na, bgcolor = color.new(sc, 80))
                array.push(kdBoxes, b1)
                array.push(kdBoxes, b2)
                array.push(kdBoxes, b3)

        // Zero line
        float zeroPct = (0.0 - domLo) / domW
        float zeroX   = domLo + zeroPct * domW
        int   zeroSl  = math.round(zeroPct * NSLICE)
        int   zeroBarX = panelX0 + math.max(0, math.min(NSLICE - 1, zeroSl))
        kdZeroLine := line.new(zeroBarX, panelBot, zeroBarX, panelTop, color = color.new(color.gray, 55), style = line.style_dotted, width = 1)
        kdZeroLbl  := label.new(zeroBarX, panelBot * 0.998, "0", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(color.gray, 50), size = size.tiny)

        // Median line
        float medPct  = (probMed - domLo) / domW
        int   medSl   = math.round(medPct * NSLICE)
        int   medBarX = panelX0 + math.max(0, math.min(NSLICE - 1, medSl))
        string medSide = lastSigBull ? "bull" : "bear"
        kdMedLine := line.new(medBarX, panelBot, medBarX, panelTop, color = color.new(color.rgb(224, 168, 0), 30), style = line.style_dashed, width = 1)
        kdMedLbl  := label.new(medBarX, panelTop * 1.002, medSide + " · med " + str.tostring(math.round(probMed, 2)) + "%", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(color.rgb(224, 168, 0), 20), size = size.tiny)

        // Live marker (if within horizon)
        if inHorizon and not na(liveReturnSigned)
            float lvPct  = (liveReturnSigned - domLo) / domW
            int   lvSl   = math.round(lvPct * NSLICE)
            int   lvBarX = panelX0 + math.max(0, math.min(NSLICE - 1, lvSl))
            kdLiveLine := line.new(lvBarX, panelBot, lvBarX, panelBot + panelH * 0.7, color = color.new(color.white, 25), style = line.style_solid, width = 1)
            kdLiveLbl  := label.new(lvBarX, panelBot + panelH * 0.72, "live " + str.tostring(math.round(liveReturnSigned, 2)) + "%", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(color.white, 20), size = size.tiny)

// ─────────────────────────────────────────────
// § MINI READOUT TABLE (H2) — bottom-right
// ─────────────────────────────────────────────
// Chart-anchored readout — bottom-right in the future space at the last bar,
// scrolls with the chart instead of covering it (not screen-docked).
var array<label> roLbls = array.new<label>()

if barstate.islast and i_probOn and i_readoutOn
    if array.size(roLbls) > 0
        for ri = 0 to array.size(roLbls) - 1
            label.delete(array.get(roLbls, ri))
    array.clear(roLbls)
    int   roX   = bar_index + i_horizon + 26
    float roPnH = nz(panelRefHi - panelRefLo, 1.0)
    float roY0  = panelRefLo - roPnH * 0.12
    float roDy  = roPnH * 0.15
    color roBg  = color.new(color.black, 35)
    // Row 0 — indicator state
    string macdDir   = macdLine > macdLine[1] ? "rising" : "falling"
    string macdSide  = macdLine > 0.0 ? "above zero" : "below zero"
    string sigState  = crossUp ? "crossed UP" : crossDn ? "crossed DN" : (macdLine > sigLine ? "above sig" : "below sig")
    string stateStr  = "MACD " + str.tostring(math.round(macdLine, 4)) + " · " + macdDir + " · " + macdSide
    array.push(roLbls, label.new(roX, roY0, stateStr, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.white, 5), size = size.normal))

    // Row 1 — signal status
    color sigColor = lastSigBull ? i_dist_gold : i_dist_cold
    array.push(roLbls, label.new(roX, roY0 - roDy, "Signal: " + sigState, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(sigColor, 15), size = size.small))

    // Row 2 — bull stats
    string bullStatStr = bN >= i_minSamp ? "Bull crosses (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  " + str.tostring(math.round(bWR, 0)) + "% ↑  med " + str.tostring(math.round(bMed, 2)) + "%  1σ " + str.tostring(math.round(bP16, 2)) + "…" + str.tostring(math.round(bP84, 2)) + "%" : "Bull crosses: gathering — n=" + str.tostring(bN)
    array.push(roLbls, label.new(roX, roY0 - roDy * 2, bullStatStr, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(i_dist_gold, 15), size = size.small))

    // Row 3 — bear stats
    string bearStatStr = rN >= i_minSamp ? "Bear crosses (" + str.tostring(i_horizon) + "b n=" + str.tostring(rN) + "):  " + str.tostring(math.round(rWR, 0)) + "% ↑  med " + str.tostring(math.round(rMed, 2)) + "%  1σ " + str.tostring(math.round(rP16, 2)) + "…" + str.tostring(math.round(rP84, 2)) + "%" : "Bear crosses: gathering — n=" + str.tostring(rN)
    array.push(roLbls, label.new(roX, roY0 - roDy * 3, bearStatStr, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(i_dist_cold, 15), size = size.small))

    // Row 4 — Read (the theory applied to the current state; RSI gold-standard voice)
    string readStr = ""
    color  readColor = color.new(color.silver, 10)
    bool sigActiveR = not na(lastSigBar) and bar_index - lastSigBar <= i_horizon
    if not i_probOn
        readStr := "Read: probability read off"
    else if sigActiveR
        string rDir = lastSigBull ? "Bull cross" : "Bear cross"
        string rAgo = str.tostring(bar_index - lastSigBar) + "b ago"
        string rEv = ""
        if not hasStats
            rEv := "too few samples yet to judge it (n=" + str.tostring(probN) + ")"
        else if recBackedAct and longBackedAct
            rEv := "recent + long-run back follow-through (" + str.tostring(math.round(recWrAct, 0)) + "% ↑ last " + str.tostring(recNAct) + ", " + str.tostring(math.round(winRate, 0)) + "% ↑ n=" + str.tostring(probN) + ")"
        else if recBackedAct
            rEv := "recent form backs it (" + str.tostring(math.round(recWrAct, 0)) + "% ↑ last " + str.tostring(recNAct) + ") — long-run mixed"
        else if leanAct
            rEv := "recent form leans " + (lastSigBull ? "bullish" : "bearish") + " (" + str.tostring(math.round(recWrAct, 0)) + "% ↑ last " + str.tostring(recNAct) + ") — building, not yet evidence"
        else if longBackedAct
            rEv := "long-run backed, but recent form cooled (" + str.tostring(math.round(recWrAct, 0)) + "% ↑ last " + str.tostring(recNAct) + ")"
        else
            rEv := "no edge in history here (recent " + (recHasAct ? str.tostring(math.round(recWrAct, 0)) + "% ↑" : "n<15") + ", long-run " + str.tostring(math.round(winRate, 0)) + "% ↑) — treat as noise"
        readStr := "Read: " + rDir + " " + rAgo + " — " + rEv
        readColor := lastSigBull ? color.new(i_dist_gold, 10) : color.new(i_dist_cold, 10)
    else if macdLine > 0.0 and macdLine > sigLine
        readStr := "Read: above zero, above signal — bullish posture; a confirmed cross DOWN would be the bearish signal"
        readColor := color.new(i_dist_gold, 10)
    else if macdLine < 0.0 and macdLine < sigLine
        readStr := "Read: below zero, below signal — bearish posture; a confirmed cross UP would be the bullish signal"
        readColor := color.new(i_dist_cold, 10)
    else
        readStr := "Read: no active signal — MACD between zero and signal line"
    array.push(roLbls, label.new(roX, roY0 - roDy * 4, "Edge last seen — bull " + agoTxt(lastEdgeBullT) + " · bear " + agoTxt(lastEdgeBearT), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.silver, 20), size = size.small))
    array.push(roLbls, label.new(roX, roY0 - roDy * 5, readStr, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = readColor, size = size.small))
    // Row 5 — footer
    array.push(roLbls, label.new(roX, roY0 - roDy * 6, "Essentials · past signals on this chart, not a prediction", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.gray, 40), size = size.tiny))

// ─────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────
alertcondition(barstate.isconfirmed and crossUp,                                            title = "MACD Rewired: Bull Signal Cross",           message = "MACD crossed above signal line. Bullish bias — use as confluence, not a standalone entry. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and crossDn,                                            title = "MACD Rewired: Bear Signal Cross",           message = "MACD crossed below signal line. Bearish bias — use as confluence, not a standalone entry. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and zeroCrossUp,                                        title = "MACD Rewired: Zero-Line Bull Cross",         message = "MACD crossed above zero. Trend turning bullish — use as a directional filter. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and zeroCrossDn,                                        title = "MACD Rewired: Zero-Line Bear Cross",         message = "MACD crossed below zero. Trend turning bearish — use as a directional filter. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and anyBullDiv,                                         title = "MACD Rewired: Bullish Divergence",           message = "Bullish divergence detected (regular or hidden). Potential reversal zone — confirm with price structure. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and anyBearDiv,                                         title = "MACD Rewired: Bearish Divergence",           message = "Bearish divergence detected (regular or hidden). Potential reversal zone — confirm with price structure. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and crossUp and evBacked,                               title = "MACD Rewired: Bull Cross (history-backed)", message = "MACD bull cross — history on this chart backed follow-through (win rate >= 55%, positive median). Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and crossDn and evBacked,                               title = "MACD Rewired: Bear Cross (history-backed)", message = "MACD bear cross — history on this chart backed follow-through (win rate >= 55%, positive median). Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and crossUp and evBacked and signalStrength >= 0.9,    title = "MACD Rewired: Strong Bull Cross (history-backed)", message = "MACD strong-tier bull cross with history-backed edge. Deep excursion confirmed. Past signals, not a prediction.")
alertcondition(barstate.isconfirmed and crossDn and evBacked and signalStrength >= 0.9,    title = "MACD Rewired: Strong Bear Cross (history-backed)", message = "MACD strong-tier bear cross with history-backed edge. Deep excursion confirmed. Past signals, not a prediction.")
````
