# Anchored VWAP Magnetized [Probalist Essentials]

- url: https://www.tradingview.com/script/wmIH4cra-Anchored-VWAP-Magnetized-Probalist-Essentials/
- type: indicator
- pine_id: PUB;29baf515080d40c7a680aec97bfe5c53
- version: 1.0

## Description

Anchored VWAP Magnetized tracks volume-weighted average price from a chosen anchor point — session open, week start, month start, or a specific date — with ±1σ and ±2σ standard-deviation bands drawn around it. Price gravitates back toward VWAP over time; the deviation bands show how far it has stretched from that fair value.

The script is for any trader who uses VWAP as a reference — intraday, swing, or positional. The outer band is the headline: a confirmed close beyond ±2σ is the primary fade signal, and the script tracks what actually happened after those touches on your specific chart and timeframe, showing the result as a distribution.

🟡 WHY THIS VERSION

The deviation bands and the probability read together are what make this version worth keeping. Most AVWAP scripts just draw the line. This one shows where the outer band was breached historically, measures how far price moved back toward VWAP after each touch, and gives you a distribution — median, win rate, recent form — so you can see whether fading the outer band has actually worked on the thing you're trading. The heat-coloured wave tells you at a glance where price stands relative to the bands. Alerts fire on confirmed closes only, so no ghost signals. And the recent-form read watches for regime shifts — a strategy that worked for six months might have cooled, and the edge clock tells you how fresh the current read is.

🟡 HOW IT WORKS

VWAP from an anchor is a running weighted average: each bar contributes (typical_price × volume) to the cumulative sum, divided by cumulative volume. The deviation uses the computational variance formula — E[tp²] − E[tp]² — which avoids a second pass over the data and stays accurate as the anchor window grows. Both accumulators reset whenever the anchor condition fires (new session, week, month, or custom date). The bands are simply VWAP ± N × deviation, where N defaults to 1 and 2. The primary signal is a confirmed close beyond the outer band, treated as a fade signal: when price stretches that far from volume-weighted fair value, the historical tendency on most instruments is mean reversion. The probability layer records the forward %-return (in signal direction) for every past touch, computes a kernel-smoothed density, and shows the result as a bell curve anchored to the right of the chart.

🟡 KEY FEATURES
[list]
[*]Session / week / month / custom-date anchor with one selector — the killer extra
[*]±1σ and ±2σ standard-deviation bands from the same anchor-reset accumulation
[*]Heat-coloured AVWAP wave — orange/amber when price runs above, blue when below
[*]Outer-band-touch fade signal with 3-tier strength dots and hover tooltips
[*]Magnet-regime detection: when BOTH fade directions are backed by recent form, the Read names it — a ranging market where price gets pulled back to the VWAP from both sides
[*]Probability distribution: kernel-smoothed bell curve of past outer-band-touch outcomes, per direction
[*]Separate bull / bear outcome arrays — no dilution of a one-sided edge
[*]Recent-form Wilson verdict and edge clock — flags regime shifts
[*]Compact mini-readout anchored to chart (scrolls with history, not screen-docked)
[*]Forward projection cone from the last signal, scaled to price space
[*]Evidence-gated alerts that fire only when the chart's own history backed follow-through
[/list]

🟡 HOW TO USE
[list]
[*]Use the AVWAP line as dynamic fair value: price above it = bullish bias, below = bearish. The heat colour gives the read instantly.
[*]The ±1σ bands define the typical range for the anchor period. Most price action stays inside them; a touch is a stretch, not a signal by itself.
[*]A confirmed close beyond the ±2σ band is the fade signal — bearish bias when above, bullish when below. The dot size encodes how far beyond the band the close landed; larger dots = deeper excursion.
[*]Check the mini-readout before acting. If the stats show 'no edge in history here — treat as noise', the band touch has not reliably led to mean reversion on this chart. If it shows recent form backs it, the recent regime has been supportive of fades.
[*]The probability read is descriptive — it counts past outcomes on this chart and timeframe. It is not a prediction. A median of +0.3% on a 15-minute chart may not survive round-trip costs on most venues; the read is about directional bias, not net P&L.
[*]Use the anchor dropdown to match your trading frame: Session for intraday, Week for swing, Month for positional. Custom anchor lets you pin to a specific structural event (earnings, news, key pivot).
[*]Set alerts on the evidence-gated variants ('history-backed') rather than the raw band touch — they fire only when the recent regime has supported follow-through.
[*]When the Read shows the magnet regime (both fades backed), trade the bands and distrust breakouts — the chart's own record says price has been snapping back to the VWAP from both sides
[*]Weigh the median move against your round-trip costs — a backed fade with a tiny median (say +0.06% on a 15-minute chart) doesn't survive fees and spread on most venues; the edge read is about direction, not net profit
[/list]

🟡 PAIRS WELL WITH

AVWAP works well alongside a trend filter — a simple MA slope or Supertrend tells you whether fades are against a strong trend (lower probability) or in a ranging / mean-reverting environment (higher probability). A momentum oscillator like RSI adds confluence on the signal bar: an outer-band touch with RSI already oversold/overbought is a tighter read than a touch alone. For intraday use, the session VWAP from the exchange feed can run alongside as a second reference for where the day's institutional activity is anchored. Key horizontal S/R levels are a natural complement — a band touch that coincides with a known support or resistance zone is a stronger candidate for a fade than one in open air.

Anchored VWAP Magnetized gives you the classic tool — volume-weighted fair value from the anchor you choose, with deviation bands showing the stretch — plus an honest count of what past band touches actually led to on your chart. The wave colour, the distribution panel, and the edge clock together turn a standard reference line into a read you can interrogate.

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

// What it shows: Anchored VWAP from a user-chosen anchor (session, week, month, or custom date)
// with ±1σ / ±2σ deviation bands. The outer-band touch is the primary fade signal.
// Method: VWAP = cumulative(typical_price × volume) / cumulative(volume) from the anchor bar.
// Deviation = sqrt(cumulative(volume × (tp − vwap)²) / cumulative(volume)).
// How to use:
//   • AVWAP acts as dynamic fair value — price gravitates back toward it.
//   • ±1σ bands = typical range; ±2σ = extended / potential fade zone.
//   • A close beyond ±2σ is the primary signal: fade signal in that direction.
//   • Probability Read shows the historical forward-return distribution for that touch.
//   • Alerts fire on confirmed closes beyond the outer band and on trend flips.

//@version=6
indicator("Anchored VWAP Magnetized [Probalist Essentials]", shorttitle = "AVWAP [P]", overlay = true, max_labels_count = 500, max_lines_count = 100, max_boxes_count = 300, max_polylines_count = 10)

// ─────────────────────────────────────────────────────────────────────────────
// § INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// ■ Anchor
i_anchor = input.string("Session", "Anchor", options = ["Session", "Week", "Month", "Custom"], group = "■ Anchor", tooltip = "When to reset the VWAP accumulation. Session = daily open; Week/Month = Monday/month-start; Custom = a specific date you set below.")
i_custom_year = input.int(2024, "Custom year", minval = 2000, maxval = 2100, group = "■ Anchor", tooltip = "Year of the custom anchor bar. Active only when Anchor = Custom.")
i_custom_month = input.int(1, "Custom month", minval = 1, maxval = 12, group = "■ Anchor", tooltip = "Month of the custom anchor bar (1–12). Active only when Anchor = Custom.")
i_custom_day = input.int(1, "Custom day", minval = 1, maxval = 31, group = "■ Anchor", tooltip = "Day of the custom anchor bar. Active only when Anchor = Custom.")

// ■ Calculation
i_src = input.source(hlc3, "Source", group = "■ Calculation", tooltip = "Price input for VWAP. HLC/3 (typical price) is the canonical default.")
i_band1 = input.float(1.0, "Inner band (σ)", minval = 0.1, maxval = 5.0, step = 0.1, group = "■ Calculation", tooltip = "First deviation band multiplier. 1.0 = one standard deviation from VWAP.")
i_band2 = input.float(2.0, "Outer band (σ)", minval = 0.1, maxval = 10.0, step = 0.1, group = "■ Calculation", tooltip = "Second deviation band multiplier — the primary fade-signal trigger. 2.0 is the canonical default.")

// ■ Signals
i_confirm = input.int(1, "Confirm bars", minval = 0, maxval = 5, group = "■ Signals", tooltip = "Bars of confirmation before a signal fires. 0 = realtime (may repaint on the live bar); 1+ = confirmed close, no repaint. Default 1 is non-repainting.")

// ■ Higher Timeframe (display only)
i_htf_on = input.bool(false, "Show HTF AVWAP", group = "■ Higher Timeframe", tooltip = "Display the same session-anchored VWAP from a higher timeframe as a faint reference line. Display only — does not gate or score signals.")
i_htf = input.timeframe("D", "HTF timeframe", group = "■ Higher Timeframe", tooltip = "Timeframe for the optional HTF AVWAP reference line.")

// ■ Probability Read
i_prob_on = input.bool(true, "Probability Read (master)", group = "■ Probability Read", tooltip = "Master toggle for the entire probability layer: records outcomes, shows stats, draws the cone and distribution panel. Describes past signals on this chart — not a prediction.")
i_readout_on = input.bool(true, "↳ Readout panel", group = "■ Probability Read", tooltip = "Show the compact mini-readout labels to the right of the last bar.")
i_cone_on = input.bool(true, "↳ Projection Cone", group = "■ Probability Read", tooltip = "Draw the forward ±1σ cone from the most recent signal bar to the horizon.")
i_dist_on = input.bool(true, "↳ Distribution Panel (bell curve)", group = "■ Probability Read", tooltip = "Draw the kernel-smoothed return distribution to the right of the last bar.")
i_horizon = input.int(10, "Horizon (bars)", minval = 1, maxval = 100, group = "■ Probability Read", tooltip = "How many bars forward to measure outcome. Longer = captures slower moves; shorter = captures quick reactions.")
i_maxSamples = input.int(200, "Max samples", minval = 20, maxval = 500, group = "■ Probability Read", tooltip = "Maximum stored outcomes per direction. Older samples roll off when the cap is hit.")
i_minSamples = input.int(20, "Min samples", minval = 5, maxval = 50, group = "■ Probability Read", tooltip = "Minimum samples before showing statistics. Below this only 'gathering — n=x' is shown.")
i_recentWin = input.int(60, "Recent Window (outcomes)", minval = 15, maxval = 200, group = "■ Probability Read", tooltip = "Number of most-recent outcomes used for the Recent Form read. Markets shift regimes; this captures the current one.")
i_wilsonZ_str = input.string("80%", "Evidence Strictness (Wilson)", options = ["80%", "90%", "95%"], group = "■ Probability Read", tooltip = "Confidence level for the Wilson lower-bound test. 80% = more sensitive (fires earlier); 95% = stricter (fires only on strong evidence).")

// ■ Probalist Theme
i_col_hot = input.color(color.rgb(249, 115, 22), "Wave hot (bullish end)", group = "■ Probalist Theme", tooltip = "Hot end of the heat gradient — shows at the bullish extreme of the AVWAP score.")
i_col_cold = input.color(color.rgb(37, 99, 235), "Wave cold (bearish end)", group = "■ Probalist Theme", tooltip = "Cold end of the heat gradient — shows at the bearish extreme.")
i_dist_gold = input.color(color.rgb(224, 168, 0), "Gold accent (bullish)", group = "■ Probalist Theme", tooltip = "Accent colour for bullish structures: upper bands, bull signal dots, bull stats rows.")
i_dist_cold = input.color(color.rgb(50, 160, 255), "Blue accent (bearish)", group = "■ Probalist Theme", tooltip = "Accent colour for bearish structures: lower bands, bear signal dots, bear stats rows.")
i_glow = input.bool(true, "Glow Effect", group = "■ Probalist Theme", tooltip = "Stack a soft halo around the AVWAP line and fill the bands with gradient shading. Turn off for a clean minimal look.")

// ─────────────────────────────────────────────────────────────────────────────
// § PROBALIST HEAT
// ─────────────────────────────────────────────────────────────────────────────

normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

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

// ─────────────────────────────────────────────────────────────────────────────
// § ANCHOR DETECTION
// ─────────────────────────────────────────────────────────────────────────────

// Detect the anchor bar based on the selected mode
isCustomAnchor = year == i_custom_year and month == i_custom_month and dayofmonth == i_custom_day

isAnchor = switch i_anchor
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Custom"  => isCustomAnchor and not isCustomAnchor[1]
    => false

// ─────────────────────────────────────────────────────────────────────────────
// § ANCHORED VWAP CALCULATION
// ─────────────────────────────────────────────────────────────────────────────

// Cumulative accumulators, reset on anchor
var float cumPV   = 0.0
var float cumV    = 0.0
var float cumPV2  = 0.0  // for variance: cum(vol * tp^2)

if isAnchor
    cumPV  := 0.0
    cumV   := 0.0
    cumPV2 := 0.0

tpVol = i_src * volume
cumPV  := cumPV  + tpVol
cumV   := cumV   + volume
cumPV2 := cumPV2 + volume * i_src * i_src

vwapVal = cumV > 0 ? cumPV / cumV : na

// Population variance from computational formula: E[x²] - E[x]²
vwapVar  = cumV > 0 ? (cumPV2 / cumV) - (vwapVal * vwapVal) : na
vwapDev  = not na(vwapVar) and vwapVar >= 0 ? math.sqrt(vwapVar) : na

band1Up  = not na(vwapVal) and not na(vwapDev) ? vwapVal + i_band1 * vwapDev : na
band1Dn  = not na(vwapVal) and not na(vwapDev) ? vwapVal - i_band1 * vwapDev : na
band2Up  = not na(vwapVal) and not na(vwapDev) ? vwapVal + i_band2 * vwapDev : na
band2Dn  = not na(vwapVal) and not na(vwapDev) ? vwapVal - i_band2 * vwapDev : na

// ─────────────────────────────────────────────────────────────────────────────
// § HEAT SCORE — price vs VWAP, mapped to ±100
// ─────────────────────────────────────────────────────────────────────────────

// Score: how far above/below VWAP in deviation units, clamped to ±100
rawScore = not na(vwapDev) and vwapDev > 0 ? math.max(-100.0, math.min(100.0, ((close - vwapVal) / vwapDev) * 50.0)) : 0.0
cMainPos = normScore(rawScore)
cMain    = heatCol(cMainPos, 0, i_col_hot, i_col_cold)
cMainFade= heatCol(cMainPos, 45, i_col_hot, i_col_cold)

// ─────────────────────────────────────────────────────────────────────────────
// § HTF VWAP (display only)
// ─────────────────────────────────────────────────────────────────────────────

htfVwap = request.security(syminfo.tickerid, i_htf, vwapVal[1], lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// § SIGNAL DETECTION — outer-band touch (fade signal)
// ─────────────────────────────────────────────────────────────────────────────

// A signal fires when close crosses beyond the outer band (confirmed)
bullTouchRaw = not na(band2Dn) and close < band2Dn  // price below lower 2σ = bullish fade
bearTouchRaw = not na(band2Up) and close > band2Up  // price above upper 2σ = bearish fade

// Confirmed signal: the touch happened i_confirm bars ago
bullSig = bullTouchRaw[i_confirm] and barstate.isconfirmed
bearSig = bearTouchRaw[i_confirm] and barstate.isconfirmed

// Rising/falling flags for readout
isBullish = not na(vwapVal) and close > vwapVal
isBearish = not na(vwapVal) and close < vwapVal

// Zone description
zoneStr = not na(band2Up) and close > band2Up ? "above 2σ" : not na(band2Dn) and close < band2Dn ? "below 2σ" : not na(band1Up) and close > band1Up ? "above 1σ" : not na(band1Dn) and close < band1Dn ? "below 1σ" : "inside bands"

// ─────────────────────────────────────────────────────────────────────────────
// § PROBABILITY READ — outcome recording
// ─────────────────────────────────────────────────────────────────────────────

// Wilson z-values
wilsonZ = i_wilsonZ_str == "95%" ? 1.960 : i_wilsonZ_str == "90%" ? 1.645 : 1.282

var array<float> probArrBull = array.new<float>()
var array<float> probArrBear = array.new<float>()

// Signal tracker — detect signal at horizon bars ago, then record the outcome now
bullAtHorizon = not na(band2Dn[i_horizon]) and close[i_horizon] < band2Dn[i_horizon]
bearAtHorizon = not na(band2Up[i_horizon]) and close[i_horizon] > band2Up[i_horizon]

if i_prob_on and barstate.isconfirmed
    if bullAtHorizon
        float ret = (close - close[i_horizon]) / close[i_horizon] * 100.0
        array.push(probArrBull, ret)
        if array.size(probArrBull) > i_maxSamples
            array.shift(probArrBull)
    if bearAtHorizon
        // Flip sign so positive = moved in signal direction (down)
        float ret = -(close - close[i_horizon]) / close[i_horizon] * 100.0
        array.push(probArrBear, ret)
        if array.size(probArrBear) > i_maxSamples
            array.shift(probArrBear)

// Stats helper — returns [n, winRate, med, p16, p84, recentN, recentWR, recentMed, wilsonLB, recentWilsonLB]
calcStats(array<float> arr, int recentK, float zW) =>
    int   n      = array.size(arr)
    float wr     = 0.0
    float med    = 0.0
    float p16    = 0.0
    float p84    = 0.0
    int   rN     = 0
    float rWR    = 0.0
    float rMed   = 0.0
    float wLB    = 0.0
    float rWLB   = 0.0
    if n > 0
        int wins = 0
        for i = 0 to n - 1
            if array.get(arr, i) > 0
                wins += 1
        wr  := wins / n * 100.0
        med := array.median(arr)
        p16 := array.percentile_nearest_rank(arr, 16)
        p84 := array.percentile_nearest_rank(arr, 84)
        // Wilson lower bound for full sample
        float pHat = wr / 100.0
        float denom = 1.0 + zW * zW / n
        float centre = pHat + zW * zW / (2.0 * n)
        float spread = zW * math.sqrt(pHat * (1.0 - pHat) / n + zW * zW / (4.0 * n * n))
        wLB := (centre - spread) / denom * 100.0
        // Recent form
        int rStart = math.max(0, n - recentK)
        array<float> rSlice = array.slice(arr, rStart, n)
        rN := array.size(rSlice)
        if rN > 0
            int rWins = 0
            for j = 0 to rN - 1
                if array.get(rSlice, j) > 0
                    rWins += 1
            rWR  := rWins / rN * 100.0
            rMed := array.median(rSlice)
            float rPHat  = rWR / 100.0
            float rDenom = 1.0 + zW * zW / rN
            float rCentre= rPHat + zW * zW / (2.0 * rN)
            float rSpread= zW * math.sqrt(rPHat * (1.0 - rPHat) / rN + zW * zW / (4.0 * rN * rN))
            rWLB := (rCentre - rSpread) / rDenom * 100.0
    [n, wr, med, p16, p84, rN, rWR, rMed, wLB, rWLB]

[bN, bWR, bMed, bP16, bP84, bRN, bRWR, bRMed, bWLB, bRWLB] = calcStats(probArrBull, i_recentWin, wilsonZ)
[eN, eWR, eMed, eP16, eP84, eRN, eRWR, eRMed, eWLB, eRWLB] = calcStats(probArrBear, i_recentWin, wilsonZ)

// Verdict helper — five tiers; rwr (recent point-estimate win rate) drives the lean.
getVerdict(float wlb, float rwlb, float med, float rMed, float rwr, int n, int rn, int minS, bool isBull) =>
    string dir = isBull ? "bullish" : "bearish"
    string v = ""
    if n < minS
        v := "gathering — n=" + str.tostring(n)
    else if rwlb > 50.0 and rMed > 0 and wlb > 50.0 and med > 0
        v := "recent + long-run back follow-through"
    else if rwlb > 50.0 and rMed > 0
        v := "recent form backs it — long-run mixed"
    else if rn >= 15 and rMed > 0 and rwr >= 55.0
        v := "recent form leans " + dir + " — building, not yet evidence"
    else if wlb > 50.0 and med > 0
        v := "long-run backed, but recent form cooled"
    else
        v := "no edge in history here — treat as noise"
    v

bullVerdict = getVerdict(bWLB, bRWLB, bMed, bRMed, bRWR, bN, bRN, i_minSamples, true)
bearVerdict = getVerdict(eWLB, eRWLB, eMed, eRMed, eRWR, eN, eRN, i_minSamples, false)

// Is recent bull/bear backed?
bullBacked = i_prob_on and bN >= i_minSamples and bRWLB > 50.0 and bRMed > 0
bearBacked = i_prob_on and eN >= i_minSamples and eRWLB > 50.0 and eRMed > 0

// Dot glyph based on verdict
bullGlyph = bN < i_minSamples ? "○" : bullBacked ? "●" : bRN >= 15 and bRMed > 0 ? "◐" : "○"
bearGlyph = eN < i_minSamples ? "○" : bearBacked ? "●" : eRN >= 15 and eRMed > 0 ? "◐" : "○"

// Edge clock
var int bullEdgeTime = na
var int bearEdgeTime = na

if barstate.isconfirmed
    if bullBacked
        bullEdgeTime := time
    if bearBacked
        bearEdgeTime := time

edgeTimeStr(int t) =>
    string s = ""
    if na(t)
        s := "—"
    else
        int elapsed = (time - t) / 1000
        if elapsed < 3600
            s := "now"
        else if elapsed < 172800
            s := str.tostring(math.round(elapsed / 3600)) + "h ago"
        else
            s := str.tostring(math.round(elapsed / 86400)) + "d ago"
    s

bullEdgeStr = edgeTimeStr(bullEdgeTime)
bearEdgeStr = edgeTimeStr(bearEdgeTime)

// ─────────────────────────────────────────────────────────────────────────────
// § SIGNAL DOTS with HISTORY TOOLTIPS
// ─────────────────────────────────────────────────────────────────────────────

// Dot lane: ~1.4 ATR below low / above high
atrVal = ta.atr(14)
dotLaneBull = low  - 1.4 * atrVal
dotLaneBear = high + 1.4 * atrVal

// Strength measure: how far beyond the band in band-width units
bullStrength = not na(vwapDev) and vwapDev > 0 and not na(band2Dn) ? math.max(0.0, (band2Dn - close) / vwapDev) : 0.0
bearStrength = not na(vwapDev) and vwapDev > 0 and not na(band2Up) ? math.max(0.0, (close - band2Up) / vwapDev) : 0.0

getDotSize(float strength) =>
    string sz = size.normal
    if strength >= 0.9
        sz := size.huge
    else if strength >= 0.4
        sz := size.large
    sz

getDotTransp(float strength) =>
    float t = 28.0
    if strength >= 0.9
        t := 0.0
    else if strength >= 0.4
        t := 12.0
    t

// Persistent dot label arrays
var array<label> bullDotLabels = array.new<label>()
var array<int>   bullDotBars   = array.new<int>()
var array<string> bullDotBase  = array.new<string>()
var array<label> bearDotLabels = array.new<label>()
var array<int>   bearDotBars   = array.new<int>()
var array<string> bearDotBase  = array.new<string>()

// Build tooltip base string
buildTipBull() =>
    string statsLine = bN >= i_minSamples ? "recent " + str.tostring(math.round(bRWR)) + "% ↑ (last " + str.tostring(bRN) + ") · long-run " + str.tostring(math.round(bWR)) + "% ↑ · med +" + str.tostring(bMed, "0.00") + "% · n=" + str.tostring(bN) : "gathering n=" + str.tostring(bN)
    "Bull fade (below 2σ)\nRead at fire: " + statsLine + "\n→ " + bullVerdict

buildTipBear() =>
    string statsLine = eN >= i_minSamples ? "recent " + str.tostring(math.round(eRWR)) + "% ↑ (last " + str.tostring(eRN) + ") · long-run " + str.tostring(math.round(eWR)) + "% ↑ · med +" + str.tostring(eMed, "0.00") + "% · n=" + str.tostring(eN) : "gathering n=" + str.tostring(eN)
    "Bear fade (above 2σ)\nRead at fire: " + statsLine + "\n→ " + bearVerdict

// Place bull dot
if bullSig and i_prob_on
    float capStrength = bullStrength[i_confirm]
    string dotSz   = getDotSize(capStrength)
    float  dotTr   = getDotTransp(capStrength)
    string tipBase = buildTipBull()
    label lbl = label.new(bar_index, dotLaneBull, bullGlyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_gold, dotTr), size = dotSz, tooltip = tipBase + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…")
    array.push(bullDotLabels, lbl)
    array.push(bullDotBars,   bar_index)
    array.push(bullDotBase,   tipBase)
    if array.size(bullDotLabels) > 400
        label.delete(array.shift(bullDotLabels))
        array.shift(bullDotBars)
        array.shift(bullDotBase)

// Place bear dot
if bearSig and i_prob_on
    float capStrengthB = bearStrength[i_confirm]
    string dotSzB   = getDotSize(capStrengthB)
    float  dotTrB   = getDotTransp(capStrengthB)
    string tipBaseB = buildTipBear()
    label lblB = label.new(bar_index, dotLaneBear, bearGlyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_cold, dotTrB), size = dotSzB, tooltip = tipBaseB + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…")
    array.push(bearDotLabels, lblB)
    array.push(bearDotBars,   bar_index)
    array.push(bearDotBase,   tipBaseB)
    if array.size(bearDotLabels) > 400
        label.delete(array.shift(bearDotLabels))
        array.shift(bearDotBars)
        array.shift(bearDotBase)

// Update completed tooltips — only check the dot that would have fired i_horizon bars ago
if barstate.isconfirmed and i_prob_on
    int nBull = array.size(bullDotBars)
    if nBull > 0
        int targetBar = bar_index - i_horizon
        for k = 0 to nBull - 1
            if array.get(bullDotBars, k) == targetBar
                float outcome = (close - close[i_horizon]) / close[i_horizon] * 100.0
                string outStr = outcome >= 0 ? "+" + str.tostring(outcome, "0.00") + "%" : str.tostring(outcome, "0.00") + "%"
                label.set_tooltip(array.get(bullDotLabels, k), array.get(bullDotBase, k) + "\nOutcome after " + str.tostring(i_horizon) + "b: " + outStr + " (in signal direction)")
    int nBear = array.size(bearDotBars)
    if nBear > 0
        int targetBarB = bar_index - i_horizon
        for k = 0 to nBear - 1
            if array.get(bearDotBars, k) == targetBarB
                float outcomeB = -(close - close[i_horizon]) / close[i_horizon] * 100.0
                string outStrB = outcomeB >= 0 ? "+" + str.tostring(outcomeB, "0.00") + "%" : str.tostring(outcomeB, "0.00") + "%"
                label.set_tooltip(array.get(bearDotLabels, k), array.get(bearDotBase, k) + "\nOutcome after " + str.tostring(i_horizon) + "b: " + outStrB + " (in signal direction)")

// ─────────────────────────────────────────────────────────────────────────────
// § PLOTTING — AVWAP + BANDS + GLOW
// ─────────────────────────────────────────────────────────────────────────────

// Glow layers — 3-layer stacked halo around AVWAP
pGlowA = plot(vwapVal, "GlowA", color = i_glow ? color.new(cMain, 65) : na, linewidth = 7, display = display.none, editable = false)
pGlowB = plot(vwapVal, "GlowB", color = i_glow ? color.new(cMain, 80) : na, linewidth = 12, display = display.none, editable = false)
pGlowC = plot(vwapVal, "GlowC", color = i_glow ? color.new(cMain, 90) : na, linewidth = 18, display = display.none, editable = false)

// VWAP main line — heat-coloured wave
pVwap  = plot(vwapVal, "AVWAP", color = cMain, linewidth = 2)

// Band plots
pB1Up  = plot(band1Up, "Band +1σ", color = color.new(i_dist_gold, 50), linewidth = 1)
pB1Dn  = plot(band1Dn, "Band −1σ", color = color.new(i_dist_cold, 50), linewidth = 1)
pB2Up  = plot(band2Up, "Band +2σ", color = color.new(i_dist_gold, 35), linewidth = 2)
pB2Dn  = plot(band2Dn, "Band −2σ", color = color.new(i_dist_cold, 35), linewidth = 2)

// Price fill from VWAP to price (heat gradient wave)
pClose = plot(close, "Close ref", color = na, editable = false)
fill(pVwap, pClose, top_value = math.max(vwapVal, close), bottom_value = math.min(vwapVal, close), top_color = color.new(cMain, 18), bottom_color = color.new(cMain, 90))

// Band fills (glow-gated)
fill(pB1Up, pB2Up, top_value = band2Up, bottom_value = band1Up, top_color = i_glow ? color.new(i_dist_gold, 90) : na, bottom_color = i_glow ? color.new(i_dist_gold, 96) : na)
fill(pB1Dn, pB2Dn, top_value = band1Dn, bottom_value = band2Dn, top_color = i_glow ? color.new(i_dist_cold, 96) : na, bottom_color = i_glow ? color.new(i_dist_cold, 90) : na)

// HTF VWAP reference line
plot(i_htf_on ? htfVwap : na, "HTF AVWAP", color = color.new(color.white, 60), linewidth = 1, style = plot.style_line)

// ─────────────────────────────────────────────────────────────────────────────
// § SIGNAL PLOT CIRCLES (full history baseline)
// ─────────────────────────────────────────────────────────────────────────────

// These ensure signals older than the label window still appear
plot(bullSig ? dotLaneBull : na, "Bull signal history", color = color.new(i_dist_gold, 40), style = plot.style_circles, linewidth = 2)
plot(bearSig ? dotLaneBear : na, "Bear signal history", color = color.new(i_dist_cold, 40), style = plot.style_circles, linewidth = 2)

// ─────────────────────────────────────────────────────────────────────────────
// § PROBABILITY CONE (projection from most recent signal)
// ─────────────────────────────────────────────────────────────────────────────

var box    coneBullBox    = na
var box    coneBullMedBox = na
var label  coneBullLbl    = na
var box    coneBearBox    = na
var box    coneBearMedBox = na
var label  coneBearLbl    = na

var int   lastBullBar   = na
var float lastBullBase  = na
var int   lastBearBar   = na
var float lastBullMedRet = na
var float lastBullP16   = na
var float lastBullP84   = na
var float lastBearBase  = na
var float lastBearMedRet = na
var float lastBearP16   = na
var float lastBearP84   = na

// Capture signal anchor values
if bullSig and i_prob_on
    lastBullBar    := bar_index
    lastBullBase   := vwapVal
    lastBullMedRet := bMed
    lastBullP16    := bP16
    lastBullP84    := bP84

if bearSig and i_prob_on
    lastBearBar    := bar_index
    lastBearBase   := vwapVal
    lastBearMedRet := eMed
    lastBearP16    := eP16
    lastBearP84    := eP84

// Recent price range for unbounded scaling (1% return = 1% of range)
// ta.* hoisted to global scope (rule 7) — reused by panel, gather label and readout.
float refHi50 = ta.highest(close, 50)
float refHi20 = ta.highest(close, 20)
float refLo50 = ta.lowest(close, 50)
recentRange = refHi50 - refLo50
rangeScale  = recentRange > 0 ? recentRange / 100.0 : close * 0.01

if barstate.islast and i_prob_on and i_cone_on
    box.delete(coneBullBox)
    box.delete(coneBullMedBox)
    label.delete(coneBullLbl)
    box.delete(coneBearBox)
    box.delete(coneBearMedBox)
    label.delete(coneBearLbl)
    // Bull cone
    if not na(lastBullBar) and not na(lastBullBase) and bN >= i_minSamples
        int coneRight = lastBullBar + i_horizon
        float coneTop  = lastBullBase + lastBullP84 * rangeScale
        float coneBott = lastBullBase + lastBullP16 * rangeScale
        float coneMed  = lastBullBase + lastBullMedRet * rangeScale
        coneBullBox    := box.new(lastBullBar, coneTop, coneRight, coneBott, border_color = color.new(i_dist_gold, 50), bgcolor = color.new(i_dist_gold, 82))
        coneBullMedBox := box.new(lastBullBar, coneMed + rangeScale * 0.05, coneRight, coneMed - rangeScale * 0.05, border_color = color.new(i_dist_gold, 20), bgcolor = color.new(i_dist_gold, 20))
        coneBullLbl    := label.new(coneRight, coneTop, "med " + (lastBullMedRet >= 0 ? "+" : "") + str.tostring(lastBullMedRet, "0.00") + "%", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.rgb(224, 168, 0), size = size.small)
    // Bear cone
    if not na(lastBearBar) and not na(lastBearBase) and eN >= i_minSamples
        int coneRightB = lastBearBar + i_horizon
        float coneTopB  = lastBearBase + eP84 * rangeScale
        float coneBotB  = lastBearBase + eP16 * rangeScale
        float coneMedB  = lastBearBase + lastBearMedRet * rangeScale
        coneBearBox    := box.new(lastBearBar, coneTopB, coneRightB, coneBotB, border_color = color.new(i_dist_cold, 50), bgcolor = color.new(i_dist_cold, 82))
        coneBearMedBox := box.new(lastBearBar, coneMedB + rangeScale * 0.05, coneRightB, coneMedB - rangeScale * 0.05, border_color = color.new(i_dist_cold, 20), bgcolor = color.new(i_dist_cold, 20))
        coneBearLbl    := label.new(coneRightB, coneTopB, "med " + (lastBearMedRet >= 0 ? "+" : "") + str.tostring(lastBearMedRet, "0.00") + "%", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(i_dist_cold, 0), size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
// § DISTRIBUTION PANEL — KDE bell curve
// ─────────────────────────────────────────────────────────────────────────────

var array<box>    distBoxes   = array.new<box>()
var polyline      gaussLine   = na
var label         distZeroLbl = na
var label         distMedLbl  = na
var label         distLiveLbl = na
var label         distGathLbl = na
var label         distZeroLineLbl = na
var line          distZeroLine    = na
var line          distMedLine     = na
var line          distLiveLine    = na

// Panel constants (price overlay)
int   DIST_X_START = 6   // bars right of last bar
int   KDE_BINS     = 40
float PANEL_FRAC   = 0.55 // fraction of recent range for panel height (0.18 rendered a squashed bell on zoomed-out charts)

if barstate.islast and i_prob_on and i_dist_on
    // Clean up
    if array.size(distBoxes) > 0
        for bi = 0 to array.size(distBoxes) - 1
            box.delete(array.get(distBoxes, bi))
    array.clear(distBoxes)
    polyline.delete(gaussLine)
    label.delete(distZeroLbl)
    label.delete(distMedLbl)
    label.delete(distLiveLbl)
    label.delete(distGathLbl)
    label.delete(distZeroLineLbl)
    line.delete(distZeroLine)
    line.delete(distMedLine)
    line.delete(distLiveLine)
    // Use the most recent signal direction for the panel; default bull
    bool showBull = not na(lastBullBar) and (na(lastBearBar) or lastBullBar >= lastBearBar)
    array<float> activeArr = showBull ? probArrBull : probArrBear
    color accentC = showBull ? i_dist_gold : i_dist_cold
    string dirTag = showBull ? "bull" : "bear"
    int   pN = array.size(activeArr)
    if pN < i_minSamples
        distGathLbl := label.new(bar_index + DIST_X_START + KDE_BINS / 2, refHi20, dirTag + " · gathering — n=" + str.tostring(pN), style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.white, size = size.small)
    else
        float pMed   = showBull ? bMed   : eMed
        float pP16   = showBull ? bP16   : eP16
        float pP84   = showBull ? bP84   : eP84
        float pAvg   = array.avg(activeArr)
        float pStdev = nz(array.stdev(activeArr), math.abs(pP84 - pP16) / 2.0)
        // Domain
        float halfBand    = math.max(0.01, math.abs(pP84 - pP16) / 2.0)
        float domainLow   = pMed - 2.5 * halfBand
        float domainHigh  = pMed + 2.5 * halfBand
        float domainWidth = domainHigh - domainLow
        // Panel geometry in price space
        float panelHeight = PANEL_FRAC * (refHi50 - refLo50)
        float panelBase   = refHi50 + panelHeight * 0.1
        float panelTop    = panelBase + panelHeight
        int   panelXStart = bar_index + DIST_X_START
        // KDE bandwidth (Silverman)
        float bw = math.max(1.06 * nz(pStdev, halfBand) * math.pow(pN, -0.2), domainWidth / KDE_BINS)
        // Compute KDE per bin
        array<float> kdeVals = array.new<float>(KDE_BINS, 0.0)
        float kdeMax = 0.001
        for bin = 0 to KDE_BINS - 1
            float xCentre = domainLow + (bin + 0.5) * domainWidth / KDE_BINS
            float dens = 0.0
            for si = 0 to pN - 1
                float samp = array.get(activeArr, si)
                float zval = (xCentre - samp) / bw
                dens += math.exp(-0.5 * zval * zval)
            dens /= pN
            array.set(kdeVals, bin, dens)
            if dens > kdeMax
                kdeMax := dens
        // Draw boxes
        for bin = 0 to KDE_BINS - 1
            float normDens = array.get(kdeVals, bin) / kdeMax
            if normDens > 0.02
                int   bx     = panelXStart + bin
                float xFrac  = (bin + 0.5) / KDE_BINS
                color sliceC = heatCol(xFrac, 0, i_dist_gold, i_dist_cold)
                float h      = normDens * panelHeight
                float bTop   = panelBase + h
                // Three segments: top (strong), middle, base
                float seg1Bot = panelBase + h * 0.62
                float seg2Bot = panelBase + h * 0.30
                // Top segment
                box b1 = box.new(bx, bTop, bx + 1, seg1Bot, border_color = na, bgcolor = color.new(sliceC, 28))
                array.push(distBoxes, b1)
                // Middle segment
                box b2 = box.new(bx, seg1Bot, bx + 1, seg2Bot, border_color = na, bgcolor = color.new(sliceC, 55))
                array.push(distBoxes, b2)
                // Base segment
                box b3 = box.new(bx, seg2Bot, bx + 1, panelBase, border_color = na, bgcolor = color.new(sliceC, 80))
                array.push(distBoxes, b3)
        // Gaussian overlay
        array<chart.point> gaussPts = array.new<chart.point>()
        for gi = 0 to 24
            float gx     = domainLow + gi * domainWidth / 24.0
            float gzval  = (gx - pAvg) / math.max(pStdev, 0.001)
            float gpdf   = math.exp(-0.5 * gzval * gzval)
            float gY     = panelBase + gpdf * panelHeight
            int   gXbar  = panelXStart + math.round(gi * KDE_BINS / 24.0)
            array.push(gaussPts, chart.point.from_index(gXbar, gY))
        gaussLine := polyline.new(gaussPts, curved = true, line_color = color.new(color.white, 45), line_width = 1)
        // Zero line
        float zeroFrac = domainWidth > 0 ? (0.0 - domainLow) / domainWidth : 0.5
        int   zeroX    = panelXStart + math.round(zeroFrac * KDE_BINS)
        distZeroLine   := line.new(zeroX, panelBase, zeroX, panelBase + panelHeight * 0.5, color = color.new(color.gray, 40), style = line.style_dotted, width = 1)
        distZeroLineLbl := label.new(zeroX, panelBase, "0", style = label.style_label_upper_right, color = color.new(color.black, 100), textcolor = color.new(color.gray, 40), size = size.tiny)
        // Median line
        float medFrac  = domainWidth > 0 ? (pMed - domainLow) / domainWidth : 0.5
        int   medX     = panelXStart + math.round(medFrac * KDE_BINS)
        distMedLine    := line.new(medX, panelBase, medX, panelBase + panelHeight * 0.9, color = color.new(color.rgb(224, 168, 0), 20), style = line.style_dashed, width = 1)
        string medStr  = pMed >= 0 ? "+" + str.tostring(pMed, "0.00") + "%" : str.tostring(pMed, "0.00") + "%"
        distMedLbl     := label.new(medX, panelTop, dirTag + " · med " + medStr, style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.rgb(224, 168, 0), size = size.small)
        // Live marker (if inside horizon)
        if not na(lastBullBar) or not na(lastBearBar)
            int activeSigBar = showBull ? lastBullBar : lastBearBar
            float activeSigBase = showBull ? lastBullBase : lastBearBase
            bool inHorizon = not na(activeSigBar) and (bar_index - activeSigBar) <= i_horizon
            if inHorizon and not na(activeSigBase) and activeSigBase > 0
                float liveRet = (close - activeSigBase) / activeSigBase * 100.0
                float liveFrac = domainWidth > 0 ? (liveRet - domainLow) / domainWidth : 0.5
                int   liveX   = panelXStart + math.round(math.max(0.0, math.min(1.0, liveFrac)) * KDE_BINS)
                distLiveLine  := line.new(liveX, panelBase, liveX, panelBase + panelHeight * 0.70, color = color.new(color.white, 20), style = line.style_solid, width = 1)
                string liveStr = liveRet >= 0 ? "+" + str.tostring(liveRet, "0.00") + "%" : str.tostring(liveRet, "0.00") + "%"
                distLiveLbl   := label.new(liveX, panelBase + panelHeight * 0.72, "live " + liveStr, style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.white, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// § MINI-READOUT (chart-anchored label stack)
// ─────────────────────────────────────────────────────────────────────────────

var array<label> readoutLabels = array.new<label>()

if barstate.islast and i_prob_on and i_readout_on
    if array.size(readoutLabels) > 0
        for ri = 0 to array.size(readoutLabels) - 1
            label.delete(array.get(readoutLabels, ri))
    array.clear(readoutLabels)
    float recentRange2  = refHi50 - refLo50
    float rowStep       = recentRange2 * 0.105
    float readoutBase   = refLo50 - rowStep * 2.0
    int   readoutX      = bar_index + DIST_X_START + KDE_BINS / 2
    color bgCol         = color.new(color.black, 15)
    // Row 0 — state
    string dirTxt  = isBullish ? "above VWAP" : "below VWAP"
    string row0txt = "AVWAP · " + str.tostring(vwapVal, "0.00") + " · " + dirTxt + " · " + zoneStr
    // Row 1 — band context
    string band2UpStr = not na(band2Up) ? str.tostring(band2Up, "0.00") : "n/a"
    string band2DnStr = not na(band2Dn) ? str.tostring(band2Dn, "0.00") : "n/a"
    string row1txt = "+2σ " + band2UpStr + "  −2σ " + band2DnStr
    // Row 2 — bull stats
    string row2txt = ""
    if bN < i_minSamples
        row2txt := "Bull fade (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  gathering — n=" + str.tostring(bN)
    else
        row2txt := "Bull fade (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  " + str.tostring(math.round(bWR)) + "% ↑  med " + (bMed >= 0 ? "+" : "") + str.tostring(bMed, "0.00") + "%  1σ " + str.tostring(bP16, "0.00") + "…" + str.tostring(bP84, "0.00") + "%"
    // Row 3 — bear stats
    string row3txt = ""
    if eN < i_minSamples
        row3txt := "Bear fade (" + str.tostring(i_horizon) + "b n=" + str.tostring(eN) + "):  gathering — n=" + str.tostring(eN)
    else
        row3txt := "Bear fade (" + str.tostring(i_horizon) + "b n=" + str.tostring(eN) + "):  " + str.tostring(math.round(eWR)) + "% ↑  med " + (eMed >= 0 ? "+" : "") + str.tostring(eMed, "0.00") + "%  1σ " + str.tostring(eP16, "0.00") + "…" + str.tostring(eP84, "0.00") + "%"
    // Row 4 — Read
    bool lastWasBull = not na(lastBullBar) and (na(lastBearBar) or lastBullBar >= lastBearBar)
    string readVerdict = lastWasBull ? bullVerdict : bearVerdict
    string readDir = lastWasBull ? "Bull fade" : "Bear fade"
    int barsAgo = lastWasBull ? (not na(lastBullBar) ? bar_index - lastBullBar : 0) : (not na(lastBearBar) ? bar_index - lastBearBar : 0)
    color readColor = bullBacked and bearBacked ? color.new(color.rgb(167, 243, 208), 0) : lastWasBull ? color.new(i_dist_gold, 0) : color.new(i_dist_cold, 0)
    // Both fade directions backed at once = the MAGNET regime (ranging market,
    // price pulled back to VWAP from both sides) — name it instead of confusing.
    string row4txt = bullBacked and bearBacked ? "Read: magnet regime — BOTH fades backed by recent form (bull " + str.tostring(math.round(bRWR)) + "% ↑ · bear " + str.tostring(math.round(eRWR)) + "% ↑)" : "Read: " + readDir + " " + str.tostring(barsAgo) + "b ago — " + readVerdict
    // Edge clock row
    string row4bTxt = "Edge last seen — bull " + bullEdgeStr + " · bear " + bearEdgeStr
    // Row 5 — footer
    // 4 multi-line anchors instead of 7 single rows — line spacing INSIDE a label is
    // pixel-based, so the block stays readable at every vertical zoom.
    float roGap = recentRange2 * 0.16
    label rA = label.new(readoutX, readoutBase, row0txt + "\n" + row1txt, style = label.style_label_center, color = bgCol, textcolor = color.new(color.white, 5), size = size.normal)
    array.push(readoutLabels, rA)
    label rB = label.new(readoutX, readoutBase - roGap, row2txt, style = label.style_label_center, color = bgCol, textcolor = color.new(i_dist_gold, 5), size = size.normal)
    array.push(readoutLabels, rB)
    label rC = label.new(readoutX, readoutBase - roGap * 1.8, row3txt, style = label.style_label_center, color = bgCol, textcolor = color.new(i_dist_cold, 5), size = size.normal)
    array.push(readoutLabels, rC)
    label rD = label.new(readoutX, readoutBase - roGap * 3.1, row4txt + "\n" + row4bTxt + "\nEssentials · what happened after past band touches on this chart, not a prediction", style = label.style_label_center, color = bgCol, textcolor = readColor, size = size.small)
    array.push(readoutLabels, rD)

// ─────────────────────────────────────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────────────────────────────────────

// Primary band-touch signals
alertcondition(bullSig, title = "AVWAP: Bull fade signal (below −2σ)", message = "AVWAP Magnetized: close below lower 2σ band — bullish fade setup. Description of past signals, not a prediction.")
alertcondition(bearSig, title = "AVWAP: Bear fade signal (above +2σ)", message = "AVWAP Magnetized: close above upper 2σ band — bearish fade setup. Description of past signals, not a prediction.")

// Band re-entry (price returns inside ±2σ after a touch)
bullReentry = not na(band2Dn) and close >= band2Dn and close[1] < band2Dn[1] and barstate.isconfirmed
bearReentry = not na(band2Up) and close <= band2Up and close[1] > band2Up[1] and barstate.isconfirmed
alertcondition(bullReentry, title = "AVWAP: Price re-enters above −2σ", message = "AVWAP Magnetized: price crossed back above lower 2σ band — potential mean reversion in progress. Description of past signals, not a prediction.")
alertcondition(bearReentry, title = "AVWAP: Price re-enters below +2σ", message = "AVWAP Magnetized: price crossed back below upper 2σ band — potential mean reversion in progress. Description of past signals, not a prediction.")

// Inner band crosses
bullInner = not na(band1Dn) and close < band1Dn and close[1] >= band1Dn[1] and barstate.isconfirmed
bearInner = not na(band1Up) and close > band1Up and close[1] <= band1Up[1] and barstate.isconfirmed
alertcondition(bullInner, title = "AVWAP: Close below −1σ band", message = "AVWAP Magnetized: close crossed below the −1σ band. Description of past signals, not a prediction.")
alertcondition(bearInner, title = "AVWAP: Close above +1σ band", message = "AVWAP Magnetized: close crossed above the +1σ band. Description of past signals, not a prediction.")

// VWAP cross (trend flip)
vwapCrossUp   = not na(vwapVal) and close > vwapVal and close[1] <= vwapVal[1] and barstate.isconfirmed
vwapCrossDown = not na(vwapVal) and close < vwapVal and close[1] >= vwapVal[1] and barstate.isconfirmed
alertcondition(vwapCrossUp,   title = "AVWAP: Price crossed above VWAP", message = "AVWAP Magnetized: price crossed above the anchored VWAP — bullish bias. Description of past signals, not a prediction.")
alertcondition(vwapCrossDown, title = "AVWAP: Price crossed below VWAP", message = "AVWAP Magnetized: price crossed below the anchored VWAP — bearish bias. Description of past signals, not a prediction.")

// Evidence-gated alerts
alertcondition(bullSig and bullBacked, title = "AVWAP: Bull fade (history-backed)", message = "AVWAP Magnetized: bull fade signal AND recent history on this chart backed follow-through. Description of past signals, not a prediction.")
alertcondition(bearSig and bearBacked, title = "AVWAP: Bear fade (history-backed)", message = "AVWAP Magnetized: bear fade signal AND recent history on this chart backed follow-through. Description of past signals, not a prediction.")
alertcondition(bullSig and bullBacked and bullStrength[i_confirm] >= 0.9, title = "AVWAP: Strong bull fade (history-backed)", message = "AVWAP Magnetized: strong bull fade signal (tier 3 depth) AND recent history backed follow-through. Description of past signals, not a prediction.")
alertcondition(bearSig and bearBacked and bearStrength[i_confirm] >= 0.9, title = "AVWAP: Strong bear fade (history-backed)", message = "AVWAP Magnetized: strong bear fade signal (tier 3 depth) AND recent history backed follow-through. Description of past signals, not a prediction.")
````
