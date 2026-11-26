# WaveTrend X

- url: https://www.tradingview.com/script/EsEtVFFX-WaveTrend-X/
- type: indicator
- pine_id: PUB;a3b66e214c8843d2b779eaabefaf600b
- version: 1.0

## Description

[b]WaveTrend X (WVTX)[/b]

A WaveTrend rebuild from first principles. Where the classic [url=https://www.tradingview.com/script/2KE8wTuF-Indicator-WaveTrend-Oscillator-WT/]WaveTrend[/url]  ([url=https://www.tradingview.com/u/LazyBear/]LazyBear[/url]) normalizes its Channel Index by an arbitrary 0.015 constant inherited from CCI and smooths the result with double exponential moving averages, WVTX replaces both with components that adapt to the data:[list]
[*]The CI normalization uses rolling standard deviation instead of 0.015.
[*]The smoothing uses a 1-D Kalman filter with ATR-adaptive process noise instead of double-EMA.
[*]The fixed ±60 / ±53 OB/OS bands become adaptive rolling-percentile bands.
[*]Signals are gated by a Hurst regime proxy (mean-reversion vs trending) and a Shannon entropy filter (noise suppression).
[*]Liquidity quality scales line opacity so low-volume readings visually fade.
[*]All markers fire only on confirmed bars — explicitly no-repaint.[/list]
The default channel and signal periods are tuned for slower, more structural use than classic WaveTrend — see the Notes section for how to revert to classic intraday WT speeds.

[b]How it works[/b]

The oscillator is built in five layers:
1. Channel Index (std-normalized). The standard WaveTrend CI is price's deviation from a moving average, normalized by a hard-coded constant. WVTX uses:
[pine]CI = (src − anchor) / stdev × 50[/pine]
The anchor is VWMA (default) or EMA over the channel period. The stdev is computed over the same window. The constant disappears — the oscillator's amplitude now reflects actual recent volatility, not a one-size-fits-all multiplier.

2. Kalman smoothing. A 1-D Kalman filter replaces the double-EMA that produces the WT1 line in classic WaveTrend. The filter balances two tunable noise terms:[list]
[*]Process noise Q — how much you trust the CI to change between bars. Higher = faster, less smooth.
[*]Measurement noise R — how much measurement error you assume. Higher = smoother, more lag.[/list]

With ATR-adaptive Q enabled (default), Q scales with normalized ATR — so the filter responds faster in volatile conditions and smooths harder in calm ones. This addresses classic WaveTrend's weakness of being either too slow during impulsive moves or too noisy during chop, never both right at once.
WT2 is then a longer EMA of WT1 (the signal line, classic WaveTrend convention).

3. Hurst regime proxy. A two-window standard-deviation ratio approximates the Hurst exponent:
[pine]H ≈ log₂(stdev(src, n) / stdev(src, n/2))[/pine]
H > 0.5 = trending (volatility grows faster than √n); H < 0.5 = mean-reverting; H ≈ 0.5 = random walk. The configurable dead-band around 0.5 prevents constant regime-flipping near the boundary.
Signals are gated accordingly: in trending regimes, both cross directions are allowed; in mean-reverting regimes, signals only fire from the extremes (WT1 in the bottom or top 30%) where reversion probability is structurally elevated.

4. Shannon entropy noise gate. The recent return distribution is binned into 8 equal-width bins, and Shannon entropy computed:
[pine]H = −Σ pᵢ · log(pᵢ) / log(N_bins)[/pine]
Bounded [0, 1]. Low entropy = concentrated return distribution (structured market); high entropy = uniform distribution (random/noise). When entropy exceeds the configured maximum (default 0.72), signals are suppressed — the oscillator stops emitting markers in conditions where the return statistics suggest no exploitable structure.

5. Adaptive OB/OS. Instead of fixed thresholds, OB and OS bands are the configurable percentiles (default 82% and 18%) of WT1's distribution over a rolling window. The bands move as the oscillator's range shifts — useful for instruments whose volatility regime changes substantially over time.

[b]How to read it[/b]

Three lines and an area:
WT1 (main oscillator) — colored by its rolling percentile rank. Cool teal at the high extreme, slate near the middle, coral at the low extreme.
WT2 (signal line) — light slate, follows WT1 with EMA lag.
Diff = WT1 − WT2 (area) — teal area above zero, coral below. Visualizes the momentum between WT1 and the signal line.

Adaptive OB and OS bands are colored by direction (coral above, teal below), with tinted fills extending to the ±50 boundaries.

Background regime tint:[list]
[*]Teal — trending regime (Hurst above the band)
[*]Purple — mean-reverting regime (Hurst below)
[*]No tint — neutral / random walk[/list]

Entropy trace (amber, optional) — recentered around zero and scaled for visibility in the same pane. Above zero = recent returns more random than baseline; below zero = more structured.

Signal markers:[list]
[*]Teal triangle below pane — confirmed bullish cross (WT1 crosses up WT2, entropy structured, regime allows, WT1 in lower half)
[*]Coral triangle above pane — confirmed bearish cross (same gates, opposite direction, WT1 in upper half)[/list]

Markers fire only on closed bars. There is no intra-bar signal display, by design.

[b]Inputs[/b]

Price source — default hlc3.
Channel period — lookback for the VWMA/EMA anchor and stdev normalization. Default 40.
Signal period — EMA period for the WT2 signal line. Default 16.
VWMA anchor — use VWMA instead of EMA as the price anchor. Default on.
Kalman Q / R — process and measurement noise. Defaults 0.02 / 0.8.
ATR-adaptive Q — scale Q with normalized ATR. Default on.
Hurst regime gate / window / band — toggle, window, dead-band around 0.5. Defaults on / 60 / ±0.05.
Entropy noise gate / window / max — toggle, window, entropy ceiling. Defaults on / 40 / 0.72.
Liquidity quality scale / window — fade line opacity by recent volume rank. Defaults on / 50.
OB/OS rank window / overbought / oversold percentile — sets the adaptive bands. Defaults 100 / 82% / 18%.
Regime background / entropy trace — display toggles.

[b]Built-in alerts[/b][list]
[*]Bull cross — confirmed bullish crossover, gates passed
[*]Bear cross — confirmed bearish crossover, gates passed
[*]Bull cross, deep OS — bull cross from below the 20th percentile (high-quality setup)
[*]Bear cross, deep OB — bear cross from above the 80th percentile (high-quality setup)
[*]Trending regime — Hurst transitions into the trending zone
[*]Mean-rev regime — Hurst transitions into the mean-reverting zone[/list]
The two "deep" alerts are the most actionable — a confirmed cross from the extremes of the rolling distribution is structurally more interesting than a cross near the middle.

[b]Notes[/b]

The classic LazyBear WaveTrend uses channel period 10 and signal period 21 — fast, oscillator-style behavior suited to intraday momentum trading. WVTX's defaults are 40 and 16, four times slower. This is deliberate: with adaptive smoothing (Kalman + ATR), liquidity scaling, and entropy/regime gating layered on top, fast periods produce too many marginal signals for the gates to filter cleanly. Slower periods produce fewer but more structural crosses, which is where the gates earn their keep. If you want classic intraday WaveTrend behavior, set channel period to 10 and signal period to 21 — the math still works, just with more frequent (and noisier) output.
The Kalman smoother is the most consequential of the rebuilds. Classic WaveTrend's double-EMA introduces predictable lag that traders learn to anticipate; the Kalman filter's adaptive smoothing means the lag isn't constant — it tightens in fast moves and relaxes in chop. For mean-reversion traders, this means signal markers are closer to the actual reversal pivot. For trend-followers, it means the oscillator follows directional moves more responsively.
The Hurst regime gate makes the indicator behave differently in different markets. In a trending instrument (most major indices in their secular uptrends), the gate is permissive — crosses fire freely. In a mean-reverting instrument (ranging FX pairs, sideways equities), the gate restricts crosses to the extremes of the rolling distribution, where reversion probability is highest. The dead-band around 0.5 prevents flickering when the regime is ambiguous.
The entropy gate is the most novel filter. It asks a different question from regime detection: not "what kind of market is this" but "is there any structure in the recent return distribution?" When entropy is high (close to 1.0), the distribution looks essentially uniform — no recurring pattern for an oscillator to exploit. The gate stops signals from firing in those conditions, which historically catches a lot of false WaveTrend crosses during news-driven chop.
The adaptive OB/OS bands are tuned for traders who switch between instruments. Fixed ±60/±53 levels work fine on a single instrument with stable volatility; they're systematically wrong on instruments whose volatility regime changes substantially. Percentile bands self-calibrate, so the same indicator settings work across SPY, BTC, and EURUSD without manual retuning.
The non-repaint design is enforced by barstate.isconfirmed — signals fire only when the bar has closed and won't be revised. Intra-bar, you may see WT1 approaching a cross; the marker only appears once the bar closes with the cross confirmed. The conservative choice: signals you can rely on for backtesting and live execution, at the cost of waiting until the bar ends.
This is a signal generator with multiple filtering layers — but a signal is information, not an instruction.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//   WaveTrend X  (WVTX)
//   ─────────────────────────────────────────────────────────────────────────
//   WaveTrend rebuilt from first principles. The arbitrary 0.015 constant is
//   replaced with rolling standard deviation. Double-EMA lag is cut via a 1-D
//   Kalman filter with ATR-adaptive process noise. OB/OS bands move with the
//   rolling percentile distribution. A Hurst proxy gates regime-inappropriate
//   signals; a Shannon entropy gate suppresses noise.
//   Signal markers only appear on confirmed (closed) bars — no repaint.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("WaveTrend X", shorttitle="WVTX", overlay=false, precision=2)

// ── Inputs ─────────────────────────────────────────────────────────────────────

g_core  = "Core"
g_kal   = "Kalman smoother"
g_gates = "Signal gates"
g_disp  = "Display"

i_src     = input.source(hlc3, "Price source",         group=g_core)
i_useVwma = input.bool(true,   "VWMA anchor (vs EMA)", group=g_core,
     tooltip="Uses volume-weighted moving average as the price anchor instead of EMA.")
i_n1      = input.int(40, "Channel period", group=g_core, minval=2, maxval=50,
     tooltip="Lookback for the VWMA/EMA anchor and std dev normalisation.")
i_n2      = input.int(16,  "Signal period",  group=g_core, minval=2, maxval=20,
     tooltip="EMA period for the WT2 signal line.")

i_kQ     = input.float(0.02, "Kalman process noise Q",     group=g_kal, step=0.005, minval=0.001,
     tooltip="Higher = faster response, less smooth.")
i_kR     = input.float(0.8,  "Kalman measurement noise R", group=g_kal, step=0.1,   minval=0.1,
     tooltip="Higher = smoother output, more lag.")
i_kAdapt = input.bool(true,  "ATR-adaptive Q",             group=g_kal,
     tooltip="Scales Q with normalised ATR: faster in volatile conditions, smoother in calm ones.")

i_useHurst = input.bool(true,  "Hurst regime gate",   group=g_gates)
i_hurstLen = input.int(60,     "Hurst window",        group=g_gates, minval=30, maxval=200)
i_hurstThr = input.float(0.05, "Hurst band (+-0.5)",  group=g_gates, step=0.01, minval=0.01,
     tooltip="Dead-band around H=0.5. Trending above 0.5+thr, mean-reverting below 0.5-thr.")

i_useEnt   = input.bool(true,  "Entropy noise gate",  group=g_gates)
i_entLen   = input.int(40,     "Entropy window",      group=g_gates, minval=20, maxval=100)
i_entMax   = input.float(0.72, "Max entropy (0-1)",   group=g_gates, step=0.02, minval=0.3, maxval=0.99)

i_useLiq   = input.bool(true, "Liquidity quality scale", group=g_gates)
i_liqLen   = input.int(50,    "Liquidity window",        group=g_gates, minval=20)

i_rankLen  = input.int(100,   "OB/OS rank window", group=g_disp, minval=50)
i_obPct    = input.float(82.0, "Overbought %ile",  group=g_disp, step=1.0)
i_osPct    = input.float(18.0, "Oversold %ile",    group=g_disp, step=1.0)
i_showReg  = input.bool(true,  "Regime background",group=g_disp)
i_showEnt  = input.bool(true,  "Entropy trace",    group=g_disp)

// ── Channel Index — std-normalised ────────────────────────────────────────────
float anchor = i_useVwma ? ta.vwma(i_src, i_n1) : ta.ema(i_src, i_n1)
float dev    = ta.stdev(i_src, i_n1)
float ci     = dev > 0.0 ? (i_src - anchor) / dev * 50.0 : 0.0

// ── Kalman Filter — replaces EMA(ci, n2) ─────────────────────────────────────
float _atrNorm = ta.atr(14) / math.max(ta.sma(ta.atr(14), 50), 1e-10)
float _adaptQ  = i_kAdapt ? i_kQ * math.max(0.5, math.min(3.0, _atrNorm)) : i_kQ

var float kx = na
var float kp = 1.0

if na(kx)
    kx := ci
else
    float _pPred = kp + _adaptQ
    float _kGain = _pPred / (_pPred + i_kR)
    kx           := kx + _kGain * (ci - kx)
    kp           := (1.0 - _kGain) * _pPred

float wt1  = nz(kx, ci)
float wt2  = ta.ema(wt1, i_n2)
float diff = wt1 - wt2

// ── Hurst Regime Proxy ─────────────────────────────────────────────────────────
float _stdevShort = ta.stdev(i_src, math.max(2, i_hurstLen / 2))
float _stdevLong  = ta.stdev(i_src, i_hurstLen)

float hurst = na
if bar_index >= i_hurstLen
    float _r = _stdevShort > 0.0 ? _stdevLong / _stdevShort : 1.0
    hurst   := _r > 0.0 ? math.log(_r) / math.log(2.0) : 0.5

float hurstS  = ta.ema(nz(hurst, 0.5), 10)
bool  trending = hurstS > 0.5 + i_hurstThr
bool  meanRev  = hurstS < 0.5 - i_hurstThr

// ── Shannon Entropy Gate ───────────────────────────────────────────────────────
float _retSeries = i_src - i_src[1]
float _rHi       = ta.highest(_retSeries, i_entLen)
float _rLo       = ta.lowest(_retSeries,  i_entLen)

float ent = na
if bar_index >= i_entLen + 1
    int   _nB     = 8
    float _rRange = _rHi - _rLo
    if _rRange > 0.0
        array<float> _bins = array.new_float(_nB, 0.0)
        for j = 0 to i_entLen - 1
            float _ret  = i_src[j] - i_src[j + 1]
            int   _bIdx = math.min(_nB - 1, int(math.floor((_ret - _rLo) / _rRange * float(_nB))))
            if _bIdx >= 0
                array.set(_bins, _bIdx, array.get(_bins, _bIdx) + 1.0)
        float _h = 0.0
        for j = 0 to _nB - 1
            float _p = array.get(_bins, j) / float(i_entLen)
            if _p > 0.0
                _h -= _p * math.log(_p)
        ent := _h / math.log(float(_nB))

float entS      = ta.ema(nz(ent, 0.5), 5)
bool  structured = not i_useEnt or entS <= i_entMax

// ── Liquidity Quality Scale ────────────────────────────────────────────────────
float liqPct   = ta.percentrank(volume, i_liqLen) / 100.0
float liqScale = i_useLiq ? math.max(0.25, liqPct) : 1.0

// ── Adaptive OB/OS Bands ──────────────────────────────────────────────────────
float wt1Rank = ta.percentrank(wt1, i_rankLen)
float obVal   = nz(ta.percentile_nearest_rank(wt1, i_rankLen, i_obPct),  30.0)
float osVal   = nz(ta.percentile_nearest_rank(wt1, i_rankLen, i_osPct), -30.0)

// ── Signal Logic ──────────────────────────────────────────────────────────────
bool crossUp   = ta.crossover(wt1,  wt2)
bool crossDown = ta.crossunder(wt1, wt2)

bool regOk =
     not i_useHurst or
     (trending ? true :
      meanRev  ? (wt1Rank < 30.0 or wt1Rank > 70.0) :
      true)

bool sigBull = barstate.isconfirmed and crossUp   and structured and regOk and wt1Rank < 45.0
bool sigBear = barstate.isconfirmed and crossDown and structured and regOk and wt1Rank > 55.0

// ── Palette ───────────────────────────────────────────────────────────────────
color C_TEAL  = #00e5d4
color C_CORAL = #ff5252
color C_SLATE = #607d8b
color C_AMBER = #ffc107

color bgTrend = color.new(#00e5d4, 94)
color bgMeanR = color.new(#7c4dff, 94)

color wt1Hue =
     wt1 >= 0.0
     ? color.from_gradient(wt1Rank, 50.0, 100.0, C_SLATE, C_TEAL)
     : color.from_gradient(wt1Rank, 0.0,  50.0,  C_CORAL, C_SLATE)

int   liqAlpha = math.round((1.0 - liqScale) * 55.0)
color wt1Col   = color.new(wt1Hue, liqAlpha)
color diffCol  = diff >= 0.0 ? color.new(C_TEAL, 55) : color.new(C_CORAL, 55)

// ── Plots ──────────────────────────────────────────────────────────────────────

bgcolor(i_showReg and trending ? bgTrend : i_showReg and meanRev ? bgMeanR : na,
     title="Regime tint")

p_ob100 = plot(50.0,   display=display.none, editable=false)
p_ob    = plot(obVal,  "OB band", color=color.new(C_CORAL, 70), linewidth=1)
p_os    = plot(osVal,  "OS band", color=color.new(C_TEAL,  70), linewidth=1)
p_os100 = plot(-50.0,  display=display.none, editable=false)

fill(p_ob, p_ob100, color=color.new(C_CORAL, 93), title="OB zone")
fill(p_os, p_os100, color=color.new(C_TEAL,  93), title="OS zone")

hline(0, "Zero", color=color.new(C_SLATE, 30), linestyle=hline.style_dashed, linewidth=1)

plot(diff, "Diff", color=diffCol, style=plot.style_area,      linewidth=1)
plot(wt2,  "WT2",  color=color.new(C_SLATE, 25), linewidth=1)
plot(wt1,  "WT1",      color=wt1Col,  linewidth=2)

plotshape(sigBull, "Bull", shape.triangleup,   location.bottom,
     color=color.new(C_TEAL,  0), size=size.small)
plotshape(sigBear, "Bear", shape.triangledown, location.top,
     color=color.new(C_CORAL, 0), size=size.small)

plot(i_showEnt ? (entS - 0.5) * 17.5 : na, "Entropy (scaled)",
     color=color.new(C_AMBER, 55), linewidth=1)

// ── Alerts ─────────────────────────────────────────────────────────────────────
alertcondition(sigBull,
     "WVTX — Bull cross",
     "WaveTrend X: bullish crossover confirmed (entropy + regime gated)")

alertcondition(sigBear,
     "WVTX — Bear cross",
     "WaveTrend X: bearish crossover confirmed (entropy + regime gated)")

alertcondition(sigBull and wt1Rank < 20.0,
     "WVTX — Bull cross deep OS",
     "WaveTrend X: bullish cross from deep oversold — high-quality setup")

alertcondition(sigBear and wt1Rank > 80.0,
     "WVTX — Bear cross deep OB",
     "WaveTrend X: bearish cross from deep overbought — high-quality setup")

alertcondition(i_useHurst and trending and not trending[1],
     "WVTX — Trending regime",
     "WaveTrend X: market entered trending regime")

alertcondition(i_useHurst and meanRev and not meanRev[1],
     "WVTX — Mean-rev regime",
     "WaveTrend X: market entered mean-reversion regime")
````
