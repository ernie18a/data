# Reballo Regime Detector - ER + RelVol + Autocorrelation

- url: https://www.tradingview.com/script/wUY0vDaP-Reballo-Regime-Detector-ER-RelVol-Autocorrelation/
- type: indicator
- pine_id: PUB;bfe0e224ab5b41c4be1ef29d20747206
- version: 1.0

## Description

[b]What it measures[/b]

Most indicators try to tell you [i]which way[/i] price is going. This one asks a different question: [b]is the market in a mood where trend-following works, or one where fading works?[/b]

You get one number, the Regime Score, from 0 (ranging / choppy) to 1 (trending). Under the hood it blends three different ways of looking at price, each measured at three speeds (16 / 32 / 64 bars by default).


[b]The three components[/b]

[b]1. Efficiency Ratio (Kaufman)[/b]
How straight is the path? Net distance ÷ total distance travelled. Move 10 points in 10 points of wiggle: score 1.0. Wander 50 points to end up 10 higher: score 0.2. High = directional, low = chop.

[b]2. Relative Volatility[/b]
Short-window vol ÷ long-window vol (4× the short window). Quiet, compressing vol usually goes with clean trends. Expanding vol usually means transitions and churn. Capped at 2 and flipped so that "quiet" scores high.

[b]3. Lag-1 Autocorrelation[/b]
Does today's move tend to follow yesterday's? Positive = follow-through (momentum-friendly). Negative = snap-back (mean-reversion-friendly).

Components 2 and 3 get averaged into one "RelVol+AC" number. Then both that and the ER get [b]percentile-ranked over the last year[/b], so a 0.8 on BTC means the same thing as a 0.8 on a sleepy utility stock, and 4H reads the same as daily.


[b]Putting it together[/b]

Default mix is 40% Efficiency Ratio / 60% RelVol+AC, smoothed with a 16-bar EMA so it doesn't flip on every bar. Above 0.60 = trending (green). Below 0.40 = ranging (red). The middle is left grey on purpose: that's the "don't know, don't force it" zone.


[b]What's hiding in the Data Window[/b]
[list]
[*]Each component's rank on its own, so you can see [i]what[/i] is actually moving the score.
[*]Two derived weights, [b]Divergence Multiplier[/b] and [b]Convergence Multiplier[/b] (range 1 ± strength). If you run trend and mean-reversion signals side by side, these are meant to tilt between them: scale trend signals by Divergence, counter-trend signals by Convergence. At strength 0.5, a fully trending regime gives trend signals 1.5× weight and counter-trend signals 0.5×.
[/list]


[b]Ways to use it[/b]
[list]
[*][b]As a filter:[/b] only take breakouts / momentum entries when it's green, only fade when it's red.
[*][b]As a sizing knob:[/b] use the multipliers to lean in or out instead of switching strategies on and off.
[*][b]As a sanity check:[/b] when it flips, peek at the Data Window to see whether vol, path efficiency or autocorrelation moved first.
[/list]

Two alerts built in: regime → Trending and regime → Ranging.

[b]Honest limitations[/b]
[list]
[*]Needs about a year of bars (252 by default) before the ranking means anything.
[*]It tells you what the regime [i]is[/i], not when it's going to change.
[*]It doesn't care about direction. A clean crash scores as "trending" too.
[/list]

[b]Settings[/b]
[list]
[*][b]Fast / Medium / Slow[/b] — 16 / 32 / 64 — speeds for all three measures
[*][b]Weight: ER / RelVol+AC[/b] — 0.4 / 0.6 — how much each side counts
[*][b]Percentile Rank Lookback[/b] — 252 — the "last year" window
[*][b]Score Smoothing[/b] — 16 — EMA on the final score
[*][b]Trending Above / Ranging Below[/b] — 0.60 / 0.40 — where the shading kicks in
[*][b]Multiplier Strength[/b] — 0.5 — only touches the hidden multipliers
[/list]

Open source. Fork it, break it, tell me what you find.

## Source Code

````pine
// Reballo Regime Detector — ER + RelVol + Autocorrelation
// Free / open-source component of the Reballo Forecast Stack
//@version=6
indicator('Reballo Regime Detector — ER + RelVol + Autocorrelation', shorttitle = 'Reballo Regime', overlay = false, precision = 2)

//=============================================================================
// WHAT THIS DOES
//-----------------------------------------------------------------------------
// Scores the current market as TRENDING (1.0) or RANGING (0.0) by blending
// three independent measures across three speeds:
//   1. Kaufman Efficiency Ratio  — how straight the path of price is
//   2. Relative Volatility       — short-term vol vs long-term vol (vol compression favours trend)
//   3. Lag-1 Autocorrelation     — do returns follow through, or mean-revert?
// Each raw measure is percentile-ranked over a lookback so the score is
// comparable across assets and timeframes. No prediction of direction.
//=============================================================================

//-----------------------------------------------------------------------------
// INPUTS
//-----------------------------------------------------------------------------
GRP_SRC = 'Source'
src = input.source(close, 'Source', group = GRP_SRC)

GRP_LEN = 'Speeds (bars)'
lenFast = input.int(16, 'Fast',   minval = 4,  group = GRP_LEN)
lenMed  = input.int(32, 'Medium', minval = 4,  group = GRP_LEN)
lenSlow = input.int(64, 'Slow',   minval = 4,  group = GRP_LEN)

GRP_CMB = 'Combination'
wER      = input.float(0.4, 'Weight: Efficiency Ratio', minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_CMB)
wRVAC    = input.float(0.6, 'Weight: RelVol + Autocorr', minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_CMB)
normLen  = input.int(252, 'Percentile Rank Lookback', minval = 50, maxval = 2520, group = GRP_CMB, tooltip = '252 ≈ 1 year on daily bars')
smoothLn = input.int(16, 'Score Smoothing (EMA)', minval = 1, maxval = 100, group = GRP_CMB)

GRP_OUT = 'Output'
trendTh   = input.float(0.60, 'Trending Above', minval = 0.5, maxval = 1.0, step = 0.05, group = GRP_OUT)
rangeTh   = input.float(0.40, 'Ranging Below',  minval = 0.0, maxval = 0.5, step = 0.05, group = GRP_OUT)
multStr   = input.float(0.5, 'Multiplier Strength (±)', minval = 0.05, maxval = 0.5, step = 0.05, group = GRP_OUT, tooltip = 'Only affects the hidden Divergence / Convergence multipliers in the Data Window')
showBg    = input.bool(true, 'Shade Regime Background', group = GRP_OUT)

//-----------------------------------------------------------------------------
// 1. EFFICIENCY RATIO (Kaufman): |net move| / sum(|bar-to-bar moves|)
//-----------------------------------------------------------------------------
f_er(int len) =>
    direction = math.abs(src - src[len])
    path      = math.sum(math.abs(src - src[1]), len)
    path > 0 ? direction / path : 0.5

erRaw = (f_er(lenFast) + f_er(lenMed) + f_er(lenSlow)) / 3.0

//-----------------------------------------------------------------------------
// 2+3. RELATIVE VOL + AUTOCORRELATION
//   relVol  < 1 → vol compressing vs its own history → trend-friendly
//   autocorr > 0 → returns follow through → trend-friendly
//-----------------------------------------------------------------------------
f_rvac(int len) =>
    r       = src / src[1]
    volFast = ta.stdev(r, len)
    volSlow = ta.stdev(r, len * 4)
    relVol  = volSlow != 0 ? volFast / volSlow : 1.0
    ac      = ta.correlation(src - src[1], src[1] - src[2], len)
    rvTerm  = 1.0 - math.min(nz(relVol, 1.0), 2.0) / 2.0      // [0,1]
    acTerm  = (math.max(nz(ac, 0.0), -1.0) + 1.0) / 2.0       // [0,1]
    0.5 * rvTerm + 0.5 * acTerm

rvacRaw = (f_rvac(lenFast) + f_rvac(lenMed) + f_rvac(lenSlow)) / 3.0

//-----------------------------------------------------------------------------
// NORMALISE → COMBINE → SMOOTH
//-----------------------------------------------------------------------------
scoreER   = ta.percentrank(erRaw,   normLen) / 100.0
scoreRVAC = ta.percentrank(rvacRaw, normLen) / 100.0

wSum     = wER + wRVAC
rawScore = wSum > 0 ? (wER * scoreER + wRVAC * scoreRVAC) / wSum : 0.5
score    = ta.ema(rawScore, smoothLn)

//-----------------------------------------------------------------------------
// REGIME + MULTIPLIERS
//-----------------------------------------------------------------------------
isTrending = score >= trendTh
isRanging  = score <= rangeTh

// Divergence (trend-following) and Convergence (mean-reversion) weights — used downstream
divMult  = math.max(1.0 - multStr, math.min(1.0 + multStr, 1.0 + (score - 0.5) * 2.0 * multStr))
convMult = math.max(1.0 - multStr, math.min(1.0 + multStr, 1.0 - (score - 0.5) * 2.0 * multStr))

//-----------------------------------------------------------------------------
// PLOTS
//-----------------------------------------------------------------------------
cTrend = color.rgb(8, 153, 129)
cRange = color.rgb(242, 54, 69)
cMid   = color.rgb(150, 150, 150)

scoreColor = isTrending ? cTrend : isRanging ? cRange : cMid

plot(score,     'Regime Score',            color = scoreColor, linewidth = 2)
plot(scoreER,   'Efficiency Ratio (rank)', color = color.new(cTrend, 70), display = display.data_window)
plot(scoreRVAC, 'RelVol+AC (rank)',        color = color.new(cRange, 70), display = display.data_window)
plot(divMult,   'Divergence Multiplier',   display = display.data_window)
plot(convMult,  'Convergence Multiplier',  display = display.data_window)

hline(trendTh, 'Trending Threshold', color = color.new(cTrend, 50), linestyle = hline.style_dotted)
hline(0.5,     'Neutral',            color = cMid,                  linestyle = hline.style_dashed)
hline(rangeTh, 'Ranging Threshold',  color = color.new(cRange, 50), linestyle = hline.style_dotted)

bgcolor(showBg ? (isTrending ? color.new(cTrend, 90) : isRanging ? color.new(cRange, 90) : na) : na, title = 'Regime Shading')

//-----------------------------------------------------------------------------
// ALERTS
//-----------------------------------------------------------------------------
alertcondition(isTrending and not isTrending[1], 'Regime → Trending', 'Regime Detector: market entered TRENDING regime')
alertcondition(isRanging  and not isRanging[1],  'Regime → Ranging',  'Regime Detector: market entered RANGING regime')
````
