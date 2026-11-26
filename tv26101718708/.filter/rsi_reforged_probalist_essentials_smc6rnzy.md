# RSI Reforged [Probalist Essentials]

- url: https://www.tradingview.com/script/smC6RnzY-RSI-Reforged-Probalist-Essentials/
- type: indicator
- pine_id: PUB;31499d37e4e24295a5c28354332a2a38
- version: 6.0

## Description

RSI Reforged [Probalist Essentials]

RSI Reforged is the Relative Strength Index done properly for modern trading. It keeps the canonical Wilder formula intact and adds three things that actually change how you use it: adaptive OB/OS bands that move with market volatility instead of sitting at fixed 70/30, auto-labelled regular and hidden divergence on confirmed price pivots, and a forward-return distribution that shows what has historically followed each signal on your specific chart.

It is for momentum traders who want a clean, honest RSI — one that flags the readings that matter without clutter, fires alerts you can act on without worrying about repaint, and shows you the empirical track record of its own signals right on the chart.

🟡 WHY THIS VERSION

The fixed 70/30 bands lie. In a trending market RSI rarely touches 70 before the next leg; in a tight range it hits it constantly. The adaptive bands — mean ± stdev of RSI itself over a rolling window — sit where the actual extremes are for the current regime, so you get fewer false signals in trends and more useful ones in ranges. On top of that, every regular and hidden divergence is labelled automatically on confirmed pivots, no manual squinting. And the probability panel shows you, from this chart's own history, what the closing price looked like 10 bars after a band exit — the win rate, the median move, the spread. It is a description, not a promise, but it is honest in a way most RSI tools are not.

🟡 HOW IT WORKS

The RSI is canonical Wilder (RMA smoothing), optionally EMA-smoothed. The bands are the rolling mean of RSI plus/minus a stdev multiple over a configurable lookback, so overbought and oversold adapt to the regime instead of sitting at 70/30 forever. Divergence pairs confirmed price and RSI pivots within a lookback window. The probability read records, for every confirmed band exit, the percent move N bars later (sign-flipped for bearish signals so positive always means "in the signal's direction"), keeps the most recent outcomes per signal direction in separate rolling buffers (pooling both sides would dilute a one-sided edge toward 50/50), and reports the win rate, median and 16th–84th percentile range per side. The bell curve panel runs a Gaussian kernel over those same outcomes (Silverman bandwidth) and draws the smoothed density right of the last bar, with a normal distribution fitted to the sample mean and stdev overlaid in white — where the fill and the white line disagree, the outcomes are skewed or fat-tailed. All of it is descriptive statistics of this chart's own history, not a forecast.

🟡 KEY FEATURES

 • Adaptive OB/OS bands: rolling mean ± stdev of RSI replaces the fixed 70/30 — bands sit where the extremes actually are for the current regime
 • Regular + hidden divergence, auto-labelled on confirmed pivots (gold = bullish, blue = bearish, dimmed = hidden)
 • Weighted signal dots: band exits render as gold/blue dots — a deeper stretch beyond the band draws a bigger dot, and the fill shows the evidence at fire time (● history backed it, ◐ mixed, ○ no edge measured); hover any dot for its read and outcome
 • Probability read: every band exit's forward return (default 10 bars) is recorded separately per direction; the mini-readout shows win rate, median and the 16–84% range with n for bull and bear exits side by side
 • The bell curve: a kernel-smoothed distribution of those outcomes for the side of the most recent signal, docked top-right of the last bar, running blue → gold through the Probalist heat ramp, with the fitted Gaussian as a white reference line
 • Projection cone from the most recent signal spanning the historical 16–84% band
 • Live marker: the still-open signal's running return shown inside the distribution, explicitly labelled live
 • Heat gradient wave with a 3-layer glow (one toggle kills all of it for a minimal look)
 • Optional display-only higher-timeframe RSI reference line
 • Complete alert set, all fired on confirmed bars only — nothing repaints by default
 • Read row: one plain-language line applying the stats to the current state — the signal, its age, and whether this chart's history backed it (backed / mixed / no edge)
 • Evidence-gated alerts: besides the full alert set, history-backed variants that only fire when the chart's own record supported follow-through at that moment


🟡 HOW TO USE

 • Watch the band exits: RSI leaving the oversold band upward (gold dot below) reads as bullish bias; leaving the overbought band downward (blue dot above) as bearish bias
 • Bigger dots = deeper excursions before the exit — historically the heavier version of the signal
 • Check the readout before acting on a signal: the win rate, median move and 16–84% range tell you what this signal actually did on THIS chart and timeframe — and n tells you how much that's worth
 • The bell curve makes the same point visually: a wide, flat curve means noisy outcomes; a tight curve shifted past zero means the signal has had follow-through here
 • Divergence labels are confluence, not standalone entries — strongest when they land at a band extreme
 • Treat the whole probability layer as a description of history, not a prediction
 • Optional: enable the HTF line for higher-timeframe context (display only — it gates nothing)


🟡 PAIRS WELL WITH

RSI Reforged is a momentum tool — it tells you where the oscillator stands and where divergences are forming, but it does not tell you whether the trend is with you or where support and resistance sit. Pair it with a trend-following tool (a moving average or Supertrend) to filter band exits in the direction of the dominant trend, since OS readings in a downtrend are often continuation setups, not reversals. A volume indicator helps confirm whether a divergence has conviction behind it — a divergence on light volume is weaker than one where the volume profile is also shifting. For higher-timeframe context the built-in HTF line is a start, but a dedicated HTF bias indicator can help avoid fading a strong higher-timeframe trend. Key price levels (support, resistance, prior highs/lows) are worth having on the chart too — a band exit into a clean level reads differently from one in open space.

RSI Reforged gives you the classic oscillator with the two upgrades that matter most in practice: bands that fit the current regime and divergence that labels itself on confirmed pivots. The probability panel adds a layer of honest self-assessment — you can see exactly how the signal has performed on your chart without relying on backtested promises. It is a momentum read, not a trading system, and it is built to be trusted.

Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.

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

// What it shows: RSI with adaptive OB/OS bands (mean ± N·stdev of RSI history), auto-labelled
// regular + hidden divergence on confirmed pivots, and a forward-return distribution
// after every band-exit signal — the Probalist probability read.
// Method: Canonical Wilder RSI (RMA smoothing). Bands replace fixed 70/30 with a rolling
// mean ± stdev of RSI itself, so they widen in volatile markets and tighten in ranging ones.
// Divergence is detected via confirmed pivot highs/lows (no repaint). Smoothing is optional.
// How to use:
//   • Adaptive band exits = primary signal: RSI crossing upward out of OS band is bullish bias;
//     crossing downward out of OB band is bearish bias.
//   • Divergence labels flag exhaustion; treat as confluence with the band read.
//   • The probability cone + panel show what happened after past signals on THIS chart —
//     description of history, not a prediction.
//   • HTF readout (off by default) gives a quick higher-timeframe RSI context line.

//@version=6
indicator(title = "RSI Reforged [Probalist Essentials]", shorttitle = "RSI [P]", overlay = false, max_lines_count = 100, max_labels_count = 500, max_boxes_count = 300, max_polylines_count = 5)

// ─────────────────────────────────────────────
// § INPUTS
// ─────────────────────────────────────────────

grp_calc = "■ Calculation"
i_src        = input.source(close,  "Source",          group = grp_calc, tooltip = "Price source fed into the RSI. Close is standard; HLC3 smooths the series slightly.")
i_len        = input.int(14,        "RSI Length",       group = grp_calc, minval = 2, maxval = 200, tooltip = "Lookback for Wilder's RSI. 14 is the canonical default; shorter = noisier, longer = slower.")
i_smooth     = input.int(1,         "Smoothing (EMA)",  group = grp_calc, minval = 1, maxval = 20,  tooltip = "EMA applied to raw RSI. 1 = no smoothing. Raise to reduce noise; lowers responsiveness.")
i_band_len   = input.int(100,       "Band Lookback",    group = grp_calc, minval = 20, maxval = 500, tooltip = "Rolling window for computing the mean and stdev of RSI used to place adaptive OB/OS bands.")
i_band_mult  = input.float(1.5,     "Band Width (stdev)", group = grp_calc, minval = 0.5, maxval = 4.0, step = 0.1, tooltip = "Number of RSI stdevs above/below the rolling mean for the OB/OS bands. Higher = fewer signals.")

grp_div = "■ Divergence"
i_div_on     = input.bool(true,  "Show Divergence",        group = grp_div, tooltip = "Detect and label regular + hidden divergence between price and RSI on confirmed pivot highs/lows.")
i_piv_left   = input.int(5,      "Pivot Left Bars",         group = grp_div, minval = 2, maxval = 20, tooltip = "Bars to the left required for a pivot to be confirmed. More = stronger pivots, more lag.")
i_piv_right  = input.int(5,      "Pivot Right Bars",        group = grp_div, minval = 2, maxval = 20, tooltip = "Bars to the right required for a pivot to be confirmed. Signals appear this many bars after the pivot.")
i_div_range  = input.int(60,     "Max Divergence Lookback", group = grp_div, minval = 10, maxval = 200, tooltip = "Maximum bars back to search for a prior pivot to pair with the current one for divergence.")
i_show_bull  = input.bool(true,  "Show Bullish Divergence", group = grp_div, tooltip = "Show labels for regular bullish (price LL, RSI HL) and hidden bullish (price HL, RSI LL) divergence.")
i_show_bear  = input.bool(true,  "Show Bearish Divergence", group = grp_div, tooltip = "Show labels for regular bearish (price HH, RSI LH) and hidden bearish (price LH, RSI HH) divergence.")

grp_sig = "■ Signals"
i_confirm    = input.int(1,  "Confirm bars", group = grp_sig, minval = 0, maxval = 5, tooltip = "Bars of confirmation before a band-exit signal fires. 0 = realtime (may repaint on live bar); 1+ = confirmed, non-repainting. Default 1 is the recommended honest mode.")

grp_htf = "■ Higher Timeframe"
i_htf_on     = input.bool(false, "Show HTF RSI Line",  group = grp_htf, tooltip = "Displays the RSI (same length) on a higher timeframe as a faint reference line. Display only — does not gate signals.")
i_htf        = input.timeframe("240", "HTF Timeframe", group = grp_htf, tooltip = "The higher timeframe for the optional reference RSI. Ignored when HTF line is off.")

grp_theme = "■ Probalist Theme"
i_col_hot    = input.color(color.rgb(249, 115, 22),   "Wave hot (bullish end)",  group = grp_theme, tooltip = "Hot end of the Heat ramp that colours the RSI wave and its glow. The ramp runs cold → cyan → light blue → mint → yellow → amber → this colour.")
i_col_cold   = input.color(color.rgb(37, 99, 235),  "Wave cold (bearish end)", group = grp_theme, tooltip = "Cold end of the Heat ramp that colours the RSI wave and its glow.")
i_glow       = input.bool(true, "Glow Effect",        group = grp_theme, tooltip = "The signature Probalist glow: the halo fill around the wave AND the OB/OS zone shading. Off = a clean minimal wave only.")

grp_prob = "■ Probability Read"
i_prob_on    = input.bool(true,  "Probability Read (master)", group = grp_prob, tooltip = "Track forward returns after each band-exit signal on this chart and display the distribution. Description of history — not a prediction.")
i_horizon    = input.int(10,     "Horizon (bars)",           group = grp_prob, minval = 1, maxval = 50,  tooltip = "How many bars forward to measure the outcome after each signal. Default 10.")
i_max_samp   = input.int(200,    "Max Samples",              group = grp_prob, minval = 50, maxval = 500, tooltip = "Maximum number of past outcomes stored. Oldest are dropped when the buffer is full.")
i_min_samp   = input.int(20,     "Min Samples (show stats)", group = grp_prob, minval = 5, maxval = 50,  tooltip = "Minimum samples required before showing statistics. Below this shows 'gathering — n=x'.")
i_recent_n   = input.int(60,     "Recent Window (outcomes)",  group = grp_prob, minval = 15, maxval = 100, tooltip = "How many of the most recent outcomes per direction form the RECENT FORM read. Markets move in regimes — the recent window shows whether the signal works NOW, not averaged over years.")
i_evid       = input.string("80%", "Evidence Strictness (Wilson)", group = grp_prob, options = ["80%", "90%", "95%"], tooltip = "Confidence level for the Wilson evidence test behind the backed verdict. 80% = more sensitive (edge shows sooner), 95% = strictest.")
float zEv    = i_evid == "95%" ? 1.960 : i_evid == "90%" ? 1.645 : 1.282
i_cone_on    = input.bool(true,  "↳ Projection Cone",     group = grp_prob, tooltip = "Draws a forward projection box from the most recent signal showing the 16th–84th percentile band and median.")
i_dist_on    = input.bool(true,  "↳ Distribution Panel (bell curve)",  group = grp_prob, tooltip = "The bell-curve window right of the last bar: a kernel-smoothed distribution of past forward returns in theme heat colours, with the fitted Gaussian overlaid.")
i_readout_on = input.bool(true,  "↳ Readout panel",          group = grp_prob, tooltip = "The chart-anchored info block bottom right (state, per-direction stats, edge clock, Read). Hidden when the master is off.")
i_dist_gold  = input.color(color.rgb(224, 168, 0),  "Gold accent (bullish)", group = grp_theme, tooltip = "The Probalist gold accent: OB band, bullish signal dots and the with-the-signal side of the bell curve.")
i_dist_cold  = input.color(color.rgb(50, 160, 255), "Blue accent (bearish)", group = grp_theme, tooltip = "The Probalist blue accent: OS band, bearish signal dots and the against-the-signal side of the bell curve.")

// ─────────────────────────────────────────────
// § RSI CALCULATION
// ─────────────────────────────────────────────

float rsiRaw  = ta.rsi(i_src, i_len)
float rsiVal  = i_smooth > 1 ? ta.ema(rsiRaw, i_smooth) : rsiRaw
float rsiMean = ta.sma(rsiVal, i_band_len)
float rsiStd  = ta.stdev(rsiVal, i_band_len)
float bandOB  = rsiMean + i_band_mult * rsiStd
float bandOS  = rsiMean - i_band_mult * rsiStd
float obLine  = math.min(bandOB, 95.0)
float osLine  = math.max(bandOS, 5.0)
float midLine = rsiMean

// ─────────────────────────────────────────────
// § PROBALIST HEAT (inlined from the Visual Engine — OS scripts are self-contained)
// ─────────────────────────────────────────────
// Score (−100..+100) → 0..1 position for colour lookups.
normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

// The Heat ramp: cold → ice blue → white → yellow → hot. pos is 0..1.
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
// § HEAT COLOUR
// ─────────────────────────────────────────────

float state = (rsiVal - 50.0) * 2.0
float pos   = normScore(state)
color cMain = heatCol(pos, 0, i_col_hot, i_col_cold)

// ─────────────────────────────────────────────
// § BAND-EXIT SIGNALS
// ─────────────────────────────────────────────

bool rawBullExit = rsiVal > osLine and rsiVal[1] <= osLine[1]
bool rawBearExit = rsiVal < obLine and rsiVal[1] >= obLine[1]
bool bullExit    = rawBullExit[i_confirm] and barstate.isconfirmed
bool bearExit    = rawBearExit[i_confirm] and barstate.isconfirmed

// Signal weight: how deep the excursion went beyond the band before exiting.
// Deeper stretch = a heavier signal — shown as a larger dot on the chart.
var float osDepth = 0.0
var float obDepth = 0.0
// Capture the visit's max depth BEFORE resetting it on the exit bar.
float exitDepthBull = rawBullExit ? math.max(osDepth, osLine - rsiVal[1]) : na
float exitDepthBear = rawBearExit ? math.max(obDepth, rsiVal[1] - obLine) : na
osDepth := rsiVal < osLine ? math.max(osDepth, osLine - rsiVal) : rawBullExit ? 0.0 : osDepth
obDepth := rsiVal > obLine ? math.max(obDepth, rsiVal - obLine) : rawBearExit ? 0.0 : obDepth
// Three weight tiers from how deep the excursion stretched beyond the band (rolling-stdev units).
float bullDepthN = nz(exitDepthBull[i_confirm], 0.0) / math.max(rsiStd, 0.0001)
float bearDepthN = nz(exitDepthBear[i_confirm], 0.0) / math.max(rsiStd, 0.0001)
int   bullTier   = bullExit ? (bullDepthN >= 0.9 ? 3 : bullDepthN >= 0.4 ? 2 : 1) : 0
int   bearTier   = bearExit ? (bearDepthN >= 0.9 ? 3 : bearDepthN >= 0.4 ? 2 : 1) : 0
bool  bullStrong = bullTier == 3
bool  bearStrong = bearTier == 3

// ─────────────────────────────────────────────
// § DIVERGENCE
// ─────────────────────────────────────────────

float pivHiRSI   = ta.pivothigh(rsiVal, i_piv_left, i_piv_right)
float pivLoRSI   = ta.pivotlow(rsiVal,  i_piv_left, i_piv_right)
float pivHiPrice = ta.pivothigh(high,   i_piv_left, i_piv_right)
float pivLoPrice = ta.pivotlow(low,     i_piv_left, i_piv_right)

var array<int>   arrPhRsiIdx   = array.new<int>()
var array<float> arrPhRsiVal   = array.new<float>()
var array<int>   arrPhPriceIdx = array.new<int>()
var array<float> arrPhPriceVal = array.new<float>()
var array<int>   arrPlRsiIdx   = array.new<int>()
var array<float> arrPlRsiVal   = array.new<float>()
var array<int>   arrPlPriceIdx = array.new<int>()
var array<float> arrPlPriceVal = array.new<float>()

if not na(pivHiRSI)
    array.push(arrPhRsiIdx,   bar_index - i_piv_right)
    array.push(arrPhRsiVal,   pivHiRSI)
    if array.size(arrPhRsiIdx) > 50
        array.shift(arrPhRsiIdx)
        array.shift(arrPhRsiVal)

if not na(pivHiPrice)
    array.push(arrPhPriceIdx, bar_index - i_piv_right)
    array.push(arrPhPriceVal, pivHiPrice)
    if array.size(arrPhPriceIdx) > 50
        array.shift(arrPhPriceIdx)
        array.shift(arrPhPriceVal)

if not na(pivLoRSI)
    array.push(arrPlRsiIdx,   bar_index - i_piv_right)
    array.push(arrPlRsiVal,   pivLoRSI)
    if array.size(arrPlRsiIdx) > 50
        array.shift(arrPlRsiIdx)
        array.shift(arrPlRsiVal)

if not na(pivLoPrice)
    array.push(arrPlPriceIdx, bar_index - i_piv_right)
    array.push(arrPlPriceVal, pivLoPrice)
    if array.size(arrPlPriceIdx) > 50
        array.shift(arrPlPriceIdx)
        array.shift(arrPlPriceVal)

// findPrior: walk backwards through arr_idx/arr_val looking for a pivot
// within rangeLen of curIdx.
// Safety: requires sz > 1 at call site; also hard-breaks if k < 0.
findPrior(arr_idx, arr_val, curIdx, rangeLen) =>
    float pv = na
    int   pi = na
    int   sz = array.size(arr_idx)
    if sz > 1
        int k = sz - 2
        while k >= 0
            if k < 0
                k := -1
            else
                int   idx = array.get(arr_idx, k)
                float v   = array.get(arr_val, k)
                if curIdx - idx <= rangeLen and curIdx - idx >= i_piv_left + i_piv_right + 1
                    pv := v
                    pi := idx
                    k  := -1
                else
                    k := k - 1
    [pv, pi]

// ── Bullish divergence ────────────────────────
bool regBullDiv = false
bool hidBullDiv = false
int  bullDivIdx = na

if not na(pivLoRSI) and i_div_on
    int   curPlRsiIdx = bar_index - i_piv_right
    float curPlRsiVal = pivLoRSI

    float priorRsiVal  = na
    int   priorRsiIdx  = na

    if array.size(arrPlRsiIdx) > 1
        [rv, ri] = findPrior(arrPlRsiIdx, arrPlRsiVal, curPlRsiIdx, i_div_range)
        priorRsiVal := rv
        priorRsiIdx := ri

    float priorPriceVal = na
    if not na(priorRsiIdx)
        int sz4b = array.size(arrPlPriceIdx)
        if sz4b > 0
            int k2 = sz4b - 1
            while k2 >= 0
                if k2 < 0
                    k2 := -1
                else
                    int pidx2 = array.get(arrPlPriceIdx, k2)
                    if math.abs(pidx2 - priorRsiIdx) <= i_piv_right + 2
                        priorPriceVal := array.get(arrPlPriceVal, k2)
                        k2 := -1
                    else
                        k2 := k2 - 1

    float curPriceLow = na
    int sz3 = array.size(arrPlPriceIdx)
    if sz3 > 0
        int latestPriceIdx = array.get(arrPlPriceIdx, sz3 - 1)
        if math.abs(latestPriceIdx - curPlRsiIdx) <= i_piv_right + 2
            curPriceLow := array.get(arrPlPriceVal, sz3 - 1)

    if not na(priorRsiVal) and not na(priorPriceVal) and not na(curPriceLow)
        if curPriceLow < priorPriceVal and curPlRsiVal > priorRsiVal
            regBullDiv := true
            bullDivIdx := curPlRsiIdx
        if curPriceLow > priorPriceVal and curPlRsiVal < priorRsiVal
            hidBullDiv := true
            bullDivIdx := curPlRsiIdx

// ── Bearish divergence ────────────────────────
bool regBearDiv = false
bool hidBearDiv = false
int  bearDivIdx = na

if not na(pivHiRSI) and i_div_on
    int   curPhRsiIdx = bar_index - i_piv_right
    float curPhRsiVal = pivHiRSI

    float priorRsiHiVal  = na
    int   priorRsiHiIdx  = na

    if array.size(arrPhRsiIdx) > 1
        [rhv, rhi] = findPrior(arrPhRsiIdx, arrPhRsiVal, curPhRsiIdx, i_div_range)
        priorRsiHiVal := rhv
        priorRsiHiIdx := rhi

    float priorPriceHiVal = na
    if not na(priorRsiHiIdx)
        int sz4 = array.size(arrPhPriceIdx)
        if sz4 > 0
            int k3 = sz4 - 1
            while k3 >= 0
                if k3 < 0
                    k3 := -1
                else
                    int pidx3 = array.get(arrPhPriceIdx, k3)
                    if math.abs(pidx3 - priorRsiHiIdx) <= i_piv_right + 2
                        priorPriceHiVal := array.get(arrPhPriceVal, k3)
                        k3 := -1
                    else
                        k3 := k3 - 1

    float curPriceHigh = na
    int sz5 = array.size(arrPhPriceIdx)
    if sz5 > 0
        int latestPhIdx = array.get(arrPhPriceIdx, sz5 - 1)
        if math.abs(latestPhIdx - curPhRsiIdx) <= i_piv_right + 2
            curPriceHigh := array.get(arrPhPriceVal, sz5 - 1)

    if not na(priorRsiHiVal) and not na(priorPriceHiVal) and not na(curPriceHigh)
        if curPriceHigh > priorPriceHiVal and curPhRsiVal < priorRsiHiVal
            regBearDiv := true
            bearDivIdx := curPhRsiIdx
        if curPriceHigh < priorPriceHiVal and curPhRsiVal > priorRsiHiVal
            hidBearDiv := true
            bearDivIdx := curPhRsiIdx

// ─────────────────────────────────────────────
// § HTF RSI
// ─────────────────────────────────────────────

float htfRsi = request.security(syminfo.tickerid, i_htf, ta.rsi(close, i_len)[1], lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
// § PROBABILITY READ
// ─────────────────────────────────────────────

// Outcomes are recorded PER DIRECTION — pooling bull + bear dilutes a real one-sided
// edge toward 50/50 (e.g. in an uptrend bull exits can be backed while bear exits are noise).
var array<float> probArrBull = array.new<float>()
var array<float> probArrBear = array.new<float>()
var int          lastSigBar  = na
var bool         lastSigBull = true

bool sigBullPast = rawBullExit[i_confirm + i_horizon]
bool sigBearPast = rawBearExit[i_confirm + i_horizon]

if i_prob_on and barstate.isconfirmed
    if sigBullPast
        float ret = (close - close[i_horizon]) / close[i_horizon] * 100.0
        if not na(ret)
            array.push(probArrBull, ret)
            if array.size(probArrBull) > i_max_samp
                array.shift(probArrBull)
    if sigBearPast
        float ret = (close[i_horizon] - close) / close[i_horizon] * 100.0
        if not na(ret)
            array.push(probArrBear, ret)
            if array.size(probArrBear) > i_max_samp
                array.shift(probArrBear)

if bullExit
    lastSigBar  := bar_index
    lastSigBull := true
if bearExit
    lastSigBar  := bar_index
    lastSigBull := false

// ─────────────────────────────────────────────
// § DISTRIBUTION STATS
// ─────────────────────────────────────────────

calcStats(array<float> arr) =>
    int n = array.size(arr)
    bool has = n >= i_min_samp
    float med = has ? array.median(arr) : na
    float p16 = has ? array.percentile_nearest_rank(arr, 16) : na
    float p84 = has ? array.percentile_nearest_rank(arr, 84) : na
    float avg = has ? array.avg(arr) : na
    float std = has ? array.stdev(arr) : na
    int wins = 0
    if has
        for wi = 0 to n - 1
            if array.get(arr, wi) > 0
                wins += 1
    float wr = has ? wins / n * 100.0 : na
    [n, has, med, p16, p84, avg, std, wr]

[bullN, bullHas, bullMed, bullP16, bullP84, bullAvg, bullStd, bullWR] = calcStats(probArrBull)
[bearN, bearHas, bearMed, bearP16, bearP84, bearAvg, bearStd, bearWR] = calcStats(probArrBear)

// ── RECENT FORM — stats over the last K outcomes per direction (the current regime).
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

[rbN, rbHas, rbMed, rbWr] = calcRecent(probArrBull, i_recent_n)
[rdN, rdHas, rdMed, rdWr] = calcRecent(probArrBear, i_recent_n)

// ── WILSON lower bound (90% one-sided): "backed" = statistical evidence, not a fixed bar.
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

bool bullBackedLong   = bullHas and wilsonLB(bullWR, bullN) > 50.0 and bullMed > 0
bool bearBackedLong   = bearHas and wilsonLB(bearWR, bearN) > 50.0 and bearMed > 0
bool bullBackedRecent = rbHas and wilsonLB(rbWr, rbN) > 50.0 and rbMed > 0
bool bearBackedRecent = rdHas and wilsonLB(rdWr, rdN) > 50.0 and rdMed > 0
// LEAN: a building edge — point estimate ≥ 55% but the Wilson bar not yet cleared.
bool bullLeanRecent = rbHas and not bullBackedRecent and rbWr >= 55.0 and rbMed > 0
bool bearLeanRecent = rdHas and not bearBackedRecent and rdWr >= 55.0 and rdMed > 0

// Edge clock: when the recent form last qualified as backed, per direction.
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

// ACTIVE direction = the side of the most recent signal. Everything downstream
// (panel, cone, live marker, Read row, tooltips, evidence-gated alerts) reads
// these aliases, so each consumer automatically uses ITS direction's evidence.
array<float> probArr = lastSigBull ? probArrBull : probArrBear
int   probN     = lastSigBull ? bullN   : bearN
bool  hasStats  = lastSigBull ? bullHas : bearHas
float probMed   = lastSigBull ? bullMed : bearMed
float probP16   = lastSigBull ? bullP16 : bearP16
float probP84   = lastSigBull ? bullP84 : bearP84
float probAvg   = lastSigBull ? bullAvg : bearAvg
float probStdev = lastSigBull ? bullStd : bearStd
float winRate   = lastSigBull ? bullWR  : bearWR
bool  recBackedAct  = lastSigBull ? bullBackedRecent : bearBackedRecent
bool  longBackedAct = lastSigBull ? bullBackedLong   : bearBackedLong
float recWrAct      = lastSigBull ? rbWr : rdWr
int   recNAct       = lastSigBull ? rbN  : rdN
bool  recHasAct     = lastSigBull ? rbHas : rdHas
bool  leanAct       = lastSigBull ? bullLeanRecent : bearLeanRecent

// ─────────────────────────────────────────────
// § PLOTS
// ─────────────────────────────────────────────

pMain = plot(rsiVal,  "RSI", color = cMain, linewidth = 2)
pMid  = plot(midLine, "Mid", color = na, editable = false)

fill(pMain, pMid, top_value = rsiVal, bottom_value = midLine, top_color = color.new(cMain, 25), bottom_color = color.new(cMain, 92))

// Three stacked halo layers — together an unmistakable glow around the wave when ON.
pGlow1T = plot(rsiVal + 0.8, "Glow1T", color = na, editable = false, display = display.none)
pGlow1B = plot(rsiVal - 0.8, "Glow1B", color = na, editable = false, display = display.none)
pGlow2T = plot(rsiVal + 1.8, "Glow2T", color = na, editable = false, display = display.none)
pGlow2B = plot(rsiVal - 1.8, "Glow2B", color = na, editable = false, display = display.none)
pGlow3T = plot(rsiVal + 3.2, "Glow3T", color = na, editable = false, display = display.none)
pGlow3B = plot(rsiVal - 3.2, "Glow3B", color = na, editable = false, display = display.none)
fill(pGlow1T, pGlow1B, color = i_glow ? color.new(cMain, 65) : na)
fill(pGlow2T, pGlow2B, color = i_glow ? color.new(cMain, 80) : na)
fill(pGlow3T, pGlow3B, color = i_glow ? color.new(cMain, 90) : na)

plot(obLine,  "OB Band", color = color.new(i_dist_gold, 35), linewidth = 5, style = plot.style_line)
plot(osLine,  "OS Band", color = color.new(i_dist_cold, 35), linewidth = 5, style = plot.style_line)
plot(midLine, "Mean",    color = color.new(color.gray, 70), linewidth = 1, style = plot.style_line)

pOb1 = plot(obLine, "OBtop", color = na, editable = false)
pOb2 = plot(100.0,  "OBmax", color = na, editable = false)
fill(pOb1, pOb2, color = i_glow ? color.new(i_dist_gold, 88) : na)
pOs1 = plot(osLine, "OSbot", color = na, editable = false)
pOs2 = plot(0.0,    "OSmin", color = na, editable = false)
fill(pOs1, pOs2, color = i_glow ? color.new(i_dist_cold, 88) : na)

plot(i_htf_on ? htfRsi : na, "HTF RSI", color = color.new(color.gray, 40), linewidth = 3, style = plot.style_line)

hline(50, "Center", color = color.new(color.gray, 80), linestyle = hline.style_dotted)

// ─────────────────────────────────────────────
// § DIVERGENCE LABELS
// ─────────────────────────────────────────────

// Divergence labels follow the gold/blue accent system: bullish = gold, bearish = blue.
// Hidden divergence renders dimmer than regular (same hue, lower presence).
color colRegBull = i_dist_gold
color colHidBull = color.from_gradient(0.45, 0.0, 1.0, color.rgb(110, 110, 110), i_dist_gold)
color colRegBear = i_dist_cold
color colHidBear = color.from_gradient(0.45, 0.0, 1.0, color.rgb(110, 110, 110), i_dist_cold)

if i_div_on and i_show_bull and regBullDiv
    label.new(bar_index - i_piv_right, rsiVal[i_piv_right] - 3.0, "R▲", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colRegBull, 20), textcolor = color.white, style = label.style_label_up, size = size.small)

if i_div_on and i_show_bull and hidBullDiv
    label.new(bar_index - i_piv_right, rsiVal[i_piv_right] - 3.0, "H▲", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colHidBull, 20), textcolor = color.white, style = label.style_label_up, size = size.small)

if i_div_on and i_show_bear and regBearDiv
    label.new(bar_index - i_piv_right, rsiVal[i_piv_right] + 3.0, "R▼", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colRegBear, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

if i_div_on and i_show_bear and hidBearDiv
    label.new(bar_index - i_piv_right, rsiVal[i_piv_right] + 3.0, "H▼", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colHidBear, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

// ─────────────────────────────────────────────
// § SIGNAL MARKERS
// ─────────────────────────────────────────────

// Signal dots as LABELS so each carries a hover tooltip: the history read at fire
// time + (once known) the outcome. Coloured by SIGNAL DIRECTION, size = weight.
// Two layers with a clean handoff at LBL_SPAN bars back: recent signals get the
// weighted tooltip-labels, OLDER signals get plain plot-circles (no label limit).
// last_bar_index is known during replay, so the boundary is deterministic.
int LBL_SPAN = 2000
bool inLblWin = bar_index > last_bar_index - LBL_SPAN
plot(bullExit and not inLblWin ? 2.0 : na, "Bull Exit (older history)", color = color.new(i_dist_gold, 45), style = plot.style_circles, linewidth = 2)
plot(bearExit and not inLblWin ? 98.0 : na, "Bear Exit (older history)", color = color.new(i_dist_cold, 45), style = plot.style_circles, linewidth = 2)

var array<label>  sigLbls    = array.new<label>()
var array<int>    sigLblBars = array.new<int>()
var array<string> sigLblTips = array.new<string>()

makeSigTip(bool isBull, int tier) =>
    string t = (isBull ? "Bull exit" : "Bear exit") + (tier == 3 ? " · deep stretch (heavy)" : tier == 2 ? " · medium stretch" : " · shallow stretch")
    if not hasStats
        t += "\nRead at fire: history still gathering (n=" + str.tostring(probN) + ")"
    else
        string verdict = recBackedAct and longBackedAct ? "recent + long-run back follow-through" : recBackedAct ? "recent form backs it — long-run mixed" : leanAct ? "recent form leans this way — building, not yet evidence" : longBackedAct ? "long-run backed, recent form cooled" : "no edge in history here — reads as noise"
        t += "\nRead at fire: recent " + (recHasAct ? str.tostring(math.round(recWrAct, 0)) + "% ↑ (last " + str.tostring(recNAct) + ")" : "n<15") + " · long-run " + str.tostring(math.round(winRate, 0)) + "% ↑ · med " + str.tostring(math.round(probMed, 2)) + "% · n=" + str.tostring(probN)
        t += "\n→ " + verdict
    t

if (bullExit or bearExit) and inLblWin
    bool   isB  = bullExit
    int    tier = isB ? bullTier : bearTier
    string tip0 = makeSigTip(isB, tier)
    string tipP = tip0 + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…"
    color  dotCol = isB ? i_dist_gold : i_dist_cold
    int    dotTr  = tier == 3 ? 0 : tier == 2 ? 12 : 28
    string dotSz  = tier == 3 ? size.huge : tier == 2 ? size.large : size.normal
    // Dot FILL = the evidence tier at fire time: ● backed · ◐ mixed · ○ no edge / still gathering.
    string dotGl  = recBackedAct ? "●" : leanAct or longBackedAct or (hasStats and winRate > 47.0 and probMed > 0) ? "◐" : "○"
    label  lb     = label.new(bar_index, isB ? 2.0 : 98.0, dotGl, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.black, 100), textcolor = color.new(dotCol, dotTr), style = label.style_none, size = dotSz, tooltip = tipP)
    array.push(sigLbls, lb)
    array.push(sigLblBars, bar_index)
    array.push(sigLblTips, tip0)
    if array.size(sigLbls) > 400
        label.delete(array.shift(sigLbls))
        array.shift(sigLblBars)
        array.shift(sigLblTips)

// Once a signal's outcome completes (horizon bars later), write it into that dot's tooltip.
if i_prob_on and barstate.isconfirmed and (sigBullPast or sigBearPast) and array.size(sigLblBars) > 0
    float outRet = sigBullPast ? (close - close[i_horizon]) / close[i_horizon] * 100.0 : (close[i_horizon] - close) / close[i_horizon] * 100.0
    if not na(outRet)
        for k = 0 to array.size(sigLblBars) - 1
            if array.get(sigLblBars, k) == bar_index - i_horizon
                string tipDone = array.get(sigLblTips, k) + "\nOutcome after " + str.tostring(i_horizon) + "b: " + (outRet >= 0 ? "+" : "") + str.tostring(math.round(outRet, 2)) + "% (in signal direction)"
                label.set_tooltip(array.get(sigLbls, k), tipDone)
                break

// ─────────────────────────────────────────────
// Panel geometry — declared BEFORE the readout, which stacks its rows beneath it.
float PANEL_BASE   = 62.0
float PANEL_HEIGHT = 30.0
int   PANEL_OFFSET = i_horizon + 6
int   PANEL_SLICES = 40

// § MINI-READOUT TABLE
// ─────────────────────────────────────────────

// Chart-anchored readout — same bottom-right spot, but drawn in the future space
// at the last bar so it scrolls WITH the chart instead of covering it (not screen-docked).
var array<label> roLbls = array.new<label>()

if barstate.islast and i_prob_on and i_readout_on
    if array.size(roLbls) > 0
        for ri = 0 to array.size(roLbls) - 1
            label.delete(array.get(roLbls, ri))
    array.clear(roLbls)
    int   roX  = bar_index + PANEL_OFFSET + PANEL_SLICES / 2
    color roBg = color.new(color.black, 35)
    string rsiTxt   = "RSI  " + str.tostring(math.round(rsiVal, 1))
    string zoneTxt  = rsiVal >= obLine ? "OB zone" : rsiVal <= osLine ? "OS zone" : "neutral"
    string dirTxt   = rsiVal > rsiVal[1] ? "rising" : rsiVal < rsiVal[1] ? "falling" : "flat"
    string stateTxt = rsiTxt + "  " + dirTxt + "  " + zoneTxt
    string bullTxt = not i_prob_on ? "Prob read off" : not bullHas ? "Bull exits: gathering — n=" + str.tostring(bullN) : "Bull exits (" + str.tostring(i_horizon) + "b n=" + str.tostring(bullN) + "):  " + str.tostring(math.round(bullWR, 0)) + "% ↑  med " + str.tostring(math.round(bullMed, 2)) + "%  1σ " + str.tostring(math.round(bullP16, 2)) + "…" + str.tostring(math.round(bullP84, 2)) + "%"
    string bearTxt = not i_prob_on ? "" : not bearHas ? "Bear exits: gathering — n=" + str.tostring(bearN) : "Bear exits (" + str.tostring(i_horizon) + "b n=" + str.tostring(bearN) + "):  " + str.tostring(math.round(bearWR, 0)) + "% ↑  med " + str.tostring(math.round(bearMed, 2)) + "%  1σ " + str.tostring(math.round(bearP16, 2)) + "…" + str.tostring(math.round(bearP84, 2)) + "%"
    array.push(roLbls, label.new(roX, 40.0, stateTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = cMain, size = size.normal))
    array.push(roLbls, label.new(roX, 34.0, "Adaptive bands  OB " + str.tostring(math.round(obLine, 1)) + "  OS " + str.tostring(math.round(osLine, 1)), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.white, 20), size = size.small))
    // The READ — the theory applied to the current state, in plain words.
    // Descriptive only: it reports the bias and whether THIS chart's history backed it.
    string readTxt = ""
    color  readCol = color.new(color.silver, 10)
    bool sigActive = not na(lastSigBar) and bar_index - lastSigBar <= i_horizon
    if not i_prob_on
        readTxt := "Read: probability read off"
    else if sigActive
        string rDir = lastSigBull ? "Bull exit" : "Bear exit"
        string rAgo = str.tostring(bar_index - lastSigBar) + "b ago"
        string rEv  = ""
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
        readTxt := "Read: " + rDir + " " + rAgo + " — " + rEv
        readCol := lastSigBull ? color.new(i_dist_gold, 10) : color.new(i_dist_cold, 10)
    else if rsiVal <= osLine
        readTxt := "Read: stretched cold, inside the OS band — a confirmed exit UP would be the bullish signal"
        readCol := color.new(i_dist_gold, 10)
    else if rsiVal >= obLine
        readTxt := "Read: stretched hot, inside the OB band — a confirmed exit DOWN would be the bearish signal"
        readCol := color.new(i_dist_cold, 10)
    else
        readTxt := "Read: no active signal — RSI mid-range"
    array.push(roLbls, label.new(roX, 28.0, bullTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(i_dist_gold, 10), size = size.small))
    array.push(roLbls, label.new(roX, 22.0, bearTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(i_dist_cold, 10), size = size.small))
    array.push(roLbls, label.new(roX, 16.0, "Edge last seen — bull " + agoTxt(lastEdgeBullT) + " · bear " + agoTxt(lastEdgeBearT), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.silver, 20), size = size.small))
    array.push(roLbls, label.new(roX, 10.0, readTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = readCol, size = size.small))
    array.push(roLbls, label.new(roX, 4.0, "Essentials · desc of this chart's history, not a prediction", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = roBg, textcolor = color.new(color.gray, 30), size = size.tiny))

// ─────────────────────────────────────────────
// § PROBABILITY CONE
// ─────────────────────────────────────────────

var box   coneBox   = na
var line  coneMed   = na
var label coneLabel = na

if i_prob_on and i_cone_on and hasStats and not na(lastSigBar) and barstate.islast
    box.delete(coneBox)
    line.delete(coneMed)
    label.delete(coneLabel)
    float coneBase  = 50.0
    float coneTop   = math.min(coneBase + probP84, 95.0)
    float coneBot   = math.max(coneBase + probP16, 5.0)
    float coneMedY  = coneBase + probMed
    int   coneLeft  = lastSigBar
    int   coneRight = lastSigBar + i_horizon
    color coneCol   = lastSigBull ? i_col_cold : i_col_hot
    coneBox   := box.new(coneLeft, coneTop, coneRight, coneBot, border_color = color.new(coneCol, 50), bgcolor = color.new(coneCol, 82), border_width = 1)
    coneMed   := line.new(coneLeft, coneMedY, coneRight, coneMedY, color = color.new(coneCol, 30), width = 1, style = line.style_dashed)
    coneLabel := label.new(coneRight, coneMedY, "med " + str.tostring(math.round(probMed, 2)) + "%", color = color.new(color.black, 80), textcolor = color.new(coneCol, 10), style = label.style_label_left, size = size.tiny)

// ─────────────────────────────────────────────
// § DISTRIBUTION PANEL — smooth gradient bell curve (KDE), at the chart edge
// ─────────────────────────────────────────────
// Kernel-smoothed density of the outcome samples, rendered as thin box slices
// with the theme heat gradient across the domain and a vertical fade per slice
// (strong at the curve edge, soft at the base) — the same visual language as
// the wave. Boxes/polylines can only anchor to bars, so the panel lives just
// right of the last bar: in view whenever you trade the live edge.

var array<box> distBoxes    = array.new<box>()
var line       distZeroLn   = na
var line       distMedLn    = na
var label      distZeroLb   = na
var label      distMedLb    = na
var label      distGatherLb = na
var polyline   gaussPoly    = na
var line       liveLine     = na
var label      liveLabel    = na

if i_prob_on and i_dist_on and barstate.islast
    if array.size(distBoxes) > 0
        for b = 0 to array.size(distBoxes) - 1
            box.delete(array.get(distBoxes, b))
    array.clear(distBoxes)
    line.delete(distZeroLn)
    line.delete(distMedLn)
    label.delete(distZeroLb)
    label.delete(distMedLb)
    label.delete(distGatherLb)
    polyline.delete(gaussPoly)
    line.delete(liveLine)
    label.delete(liveLabel)
    int panelLeft = bar_index + PANEL_OFFSET
    if not hasStats
        distGatherLb := label.new(panelLeft, PANEL_BASE + PANEL_HEIGHT * 0.5, (lastSigBull ? "bull" : "bear") + " · gathering — n=" + str.tostring(probN), color = color.new(color.black, 80), textcolor = color.new(color.gray, 40), style = label.style_label_right, size = size.tiny)
    else
        float halfBand = math.max(math.abs(probP84 - probP16) * 0.5, 0.01)
        float domMin   = probMed - 2.5 * halfBand
        float domMax   = probMed + 2.5 * halfBand
        float domW     = domMax - domMin
        // Silverman-style kernel bandwidth — wide enough to smooth, never below one slice
        float kBw = math.max(1.06 * nz(probStdev, halfBand) * math.pow(probN, -0.2), domW / PANEL_SLICES)
        array<float> dens = array.new<float>(PANEL_SLICES, 0.0)
        float densMax = 0.0
        for si = 0 to PANEL_SLICES - 1
            float sx  = domMin + (si + 0.5) * domW / PANEL_SLICES
            float acc = 0.0
            for vj = 0 to probN - 1
                float dv = (sx - array.get(probArr, vj)) / kBw
                acc += math.exp(-0.5 * dv * dv)
            array.set(dens, si, acc)
            if acc > densMax
                densMax := acc
        for si = 0 to PANEL_SLICES - 1
            float d = densMax > 0 ? array.get(dens, si) / densMax : 0.0
            if d > 0.02
                float h    = d * PANEL_HEIGHT
                float sPos = (si + 0.5) / PANEL_SLICES
                color sc   = heatCol(sPos, 0, i_dist_gold, i_dist_cold)
                int x1 = panelLeft + si
                int x2 = panelLeft + si + 1
                box b1 = box.new(x1, PANEL_BASE + h, x2, PANEL_BASE + h * 0.62, border_color = na, bgcolor = color.new(sc, 28))
                box b2 = box.new(x1, PANEL_BASE + h * 0.62, x2, PANEL_BASE + h * 0.30, border_color = na, bgcolor = color.new(sc, 55))
                box b3 = box.new(x1, PANEL_BASE + h * 0.30, x2, PANEL_BASE, border_color = na, bgcolor = color.new(sc, 80))
                array.push(distBoxes, b1)
                array.push(distBoxes, b2)
                array.push(distBoxes, b3)
        if not na(probStdev) and probStdev > 0 and not na(probAvg)
            array<chart.point> gaussPts = array.new<chart.point>()
            for gi = 0 to 24
                float gx   = domMin + domW * gi / 24
                float expo = -0.5 * math.pow((gx - probAvg) / probStdev, 2)
                float gy   = PANEL_BASE + math.exp(expo) * PANEL_HEIGHT
                int   gxi  = panelLeft + int(math.round((gx - domMin) / domW * PANEL_SLICES))
                array.push(gaussPts, chart.point.from_index(gxi, gy))
            gaussPoly := polyline.new(gaussPts, curved = true, line_color = color.new(color.white, 45), line_width = 1)
        int zeroX = panelLeft + int(math.max(0, math.min(PANEL_SLICES, (0.0 - domMin) / domW * PANEL_SLICES)))
        int medX  = panelLeft + int(math.max(0, math.min(PANEL_SLICES, (probMed - domMin) / domW * PANEL_SLICES)))
        distZeroLn := line.new(zeroX, PANEL_BASE, zeroX, PANEL_BASE + PANEL_HEIGHT, color = color.new(color.gray, 55), width = 1, style = line.style_dotted)
        distMedLn  := line.new(medX,  PANEL_BASE, medX,  PANEL_BASE + PANEL_HEIGHT, color = color.new(#e0a800, 45), width = 1, style = line.style_dashed)
        distZeroLb := label.new(zeroX, PANEL_BASE - 1.5, "0", color = color.new(color.black, 90), textcolor = color.new(color.gray, 40), style = label.style_label_up, size = size.tiny)
        distMedLb  := label.new(medX,  PANEL_BASE + PANEL_HEIGHT + 1.5, (lastSigBull ? "bull · med " : "bear · med ") + str.tostring(math.round(probMed, 2)) + "%", color = color.new(color.black, 90), textcolor = color.new(#e0a800, 20), style = label.style_label_down, size = size.tiny)
        if not na(lastSigBar) and bar_index - lastSigBar <= i_horizon and bar_index - lastSigBar > 0
            int barsAgo = bar_index - lastSigBar
            float liveRet = lastSigBull ? (close - close[barsAgo]) / close[barsAgo] * 100.0 : (close[barsAgo] - close) / close[barsAgo] * 100.0
            int liveX = panelLeft + int(math.max(0, math.min(PANEL_SLICES, (liveRet - domMin) / domW * PANEL_SLICES)))
            liveLine  := line.new(liveX, PANEL_BASE, liveX, PANEL_BASE + PANEL_HEIGHT * 0.7, color = color.new(color.white, 15), width = 2)
            liveLabel := label.new(liveX, PANEL_BASE + PANEL_HEIGHT * 0.72, "live " + str.tostring(math.round(liveRet, 2)) + "%", color = color.new(color.black, 70), textcolor = color.new(color.white, 10), style = label.style_label_down, size = size.tiny)

// ─────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────

alertcondition(bullExit, "RSI Reforged: Bull Band Exit", "RSI Reforged — RSI crossed upward out of OS band (bullish bias)")
alertcondition(bearExit, "RSI Reforged: Bear Band Exit", "RSI Reforged — RSI crossed downward out of OB band (bearish bias)")

// Evidence-gated alerts — fire ONLY when this chart's own recorded history backed
// follow-through at evaluation time (win rate >= 55% AND median > 0; the Read row tier).
bool evBacked = recBackedAct
alertcondition(bullExit and evBacked, "RSI Reforged: Bull Exit (history-backed)", "RSI Reforged — Bullish band exit while this chart's recorded history backed follow-through (win rate >= 55%, median > 0 at evaluation). Description of past signals, not a prediction.")
alertcondition(bearExit and evBacked, "RSI Reforged: Bear Exit (history-backed)", "RSI Reforged — Bearish band exit while this chart's recorded history backed follow-through (win rate >= 55%, median > 0 at evaluation). Description of past signals, not a prediction.")
alertcondition(bullStrong and evBacked, "RSI Reforged: Strong Bull Exit (history-backed)", "RSI Reforged — DEEP bullish band exit (large dot) while this chart's recorded history backed follow-through. Description of past signals, not a prediction.")
alertcondition(bearStrong and evBacked, "RSI Reforged: Strong Bear Exit (history-backed)", "RSI Reforged — DEEP bearish band exit (large dot) while this chart's recorded history backed follow-through. Description of past signals, not a prediction.")
alertcondition(rsiVal >= obLine and barstate.isconfirmed, "RSI Reforged: OB Zone", "RSI Reforged — RSI entered adaptive overbought zone")
alertcondition(rsiVal <= osLine and barstate.isconfirmed, "RSI Reforged: OS Zone", "RSI Reforged — RSI entered adaptive oversold zone")
alertcondition(i_div_on and regBullDiv and barstate.isconfirmed, "RSI Reforged: Regular Bullish Div", "RSI Reforged — Regular bullish divergence detected (price LL, RSI HL)")
alertcondition(i_div_on and hidBullDiv and barstate.isconfirmed, "RSI Reforged: Hidden Bullish Div",  "RSI Reforged — Hidden bullish divergence detected (price HL, RSI LL)")
alertcondition(i_div_on and regBearDiv and barstate.isconfirmed, "RSI Reforged: Regular Bearish Div", "RSI Reforged — Regular bearish divergence detected (price HH, RSI LH)")
alertcondition(i_div_on and hidBearDiv and barstate.isconfirmed, "RSI Reforged: Hidden Bearish Div",  "RSI Reforged — Hidden bearish divergence detected (price LH, RSI HH)")
alertcondition(ta.crossover(rsiVal, 50.0)  and barstate.isconfirmed, "RSI Reforged: Cross Above 50", "RSI Reforged — RSI crossed above midline (50)")
alertcondition(ta.crossunder(rsiVal, 50.0) and barstate.isconfirmed, "RSI Reforged: Cross Below 50", "RSI Reforged — RSI crossed below midline (50)")
````
