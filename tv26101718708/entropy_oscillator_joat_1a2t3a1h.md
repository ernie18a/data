# Entropy Oscillator [JOAT]

- url: https://www.tradingview.com/script/1a2T3a1h-Entropy-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;4c0d5fdd8ef04eea9d271893992f34ec
- version: 1.0

## Description

[b]ENTROPY OSCILLATOR [JOAT][/b]

A pane oscillator that measures the [b]Shannon entropy[/b] of recent returns — the information-theoretic measure of how uncertain (chaotic) vs how predictable (directional) the recent distribution of price moves has been. Low entropy = the market is in a directional regime; high entropy = the market is chopping. Unlike volatility, entropy does not care about [i]how big[/i] moves are — only how [i]concentrated their distribution[/i] is. That distinction is what makes it one of the cleanest regime-classification tools in quantitative finance.

[image]https://www.tradingview.com/x/bjfGGcVX/[/image]

[b]Shannon entropy, applied to markets[/b]

For a sequence of N recent log returns, the script:

[list=1]
[*] Bins the returns into B equal-width bins across the empirical range.
[*] Computes the probability of each bin (count / N).
[*] Computes the Shannon entropy: H = −Σ p(i) · log(p(i)) over non-zero bins.
[*] Normalises to [0, 1] by dividing by log(B) — the maximum possible entropy for B bins, which corresponds to a perfectly uniform distribution.
[/list]

A perfectly uniform distribution (returns evenly spread across all bins → chaotic chop) produces normalised entropy of 1.0. A perfectly concentrated distribution (all returns in one bin → directional regime) produces entropy of 0. Real markets sit in between, and the script's job is to tell you where.

[b]Two-threshold regime classification[/b]

[list]
[*] [b]Normalised entropy < low threshold[/b] (default 0.30) → [b]DIRECTIONAL[/b] regime. The distribution of returns is concentrated; momentum tools work.
[*] [b]Normalised entropy > high threshold[/b] (default 0.70) → [b]CHOP[/b] regime. The distribution is spread; reversion tools work.
[*] [b]Between the thresholds[/b] → [b]MIXED[/b] regime. Neither side has the edge.
[/list]

The thresholds are the [i]spec-default[/i] institutional values; tighten or loosen for your instrument.

[b]Slope-coloured entropy line[/b]

The smoothed entropy series is plotted in the pane with a slope-driven colour gradient — bull colour when entropy is falling toward directional, bear colour when entropy is rising toward chop. At a glance you can see which way the regime is moving even before it has crossed a threshold.

[b]Visual system (pane + chart overlay)[/b]

In the pane:

[list]
[*] Slope-coloured entropy line.
[*] Threshold lines at low / 0.5 / high (toggleable).
[*] Translucent fill zones for the low and high regions.
[*] Pane background tint by current regime (toggleable).
[/list]

On the chart (force_overlay):

[list]
[*] [b]Bar colouring[/b] — chart bars tinted by regime (cool when directional, hot when chop, neutral when mixed). Off by default.
[*] [b]Overlay background[/b] — subtle bgcolor projected onto the main chart marking the current regime. Off by default.
[/list]

A locked Crimson Pulse palette (electric blue directional / lime-yellow chop / muted mauve mixed on a crimson-black ground) gives the pane a distinctive structural identity.

[b]Regime Suggestion dashboard row[/b]

Like its sister script Hurst Regime Sentinel, Entropy Oscillator exposes a [b]Suggested JOAT Indicator[/b] row that names the best companion script for the current regime. Defaults: [i]AlphaTrend / Kalman Quantum Drift / Doppler Velocity Shift[/i] family for Directional regimes; [i]Z-Score Reversion / Heisenberg Uncertainty Bands / Brownian Motion Residual / Renaissance Mean Reversion[/i] for Chop; [i]Liquidity Magnet / Schrödinger Zone Probability / Fractal Dimension Index[/i] for Mixed. Every suggestion is user-configurable — you pick from the JOAT suite which tool the dashboard recommends per regime.

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Current normalised entropy value.
[*] Smoothed entropy and its slope direction.
[*] Regime classification.
[*] Bars in current regime.
[*] Distance from entropy to nearest threshold.
[*] Source series + window length + bin count in use.
[*] Suggested JOAT Indicator (toggleable).
[/list]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Cross into Low Entropy (directional regime entry).
[*] Cross into High Entropy (chop regime entry).
[*] Any Regime Change (any classification flip).
[/list]

[image]https://www.tradingview.com/x/p0QPIEOh/[/image]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Entry into Low Entropy[/b] — the directional commitment signal. The recent distribution of returns has narrowed; the market is in a momentum regime. Pair with a directional indicator (the dashboard's suggestion row tells you which).
[*] [b]Entry into High Entropy[/b] — the chop confirmation signal. Returns are widely distributed; momentum tools whipsaw, reversion tools work. Pair with a reversion indicator.
[/list]

The "slope of entropy" itself is the leading read — when the line is falling toward the low threshold, a directional regime is forming; when it is rising toward the high threshold, chop is building. You do not need to wait for the threshold cross if you trust the slope gradient.

[b]Suggested settings[/b]

Defaults (window 50 returns, 10 bins, EMA smoothing 3) are tuned for 15m–4H on liquid markets. The rule of thumb is window / bins ≥ 5 so each bin has enough samples to be statistically meaningful. For lower timeframes drop window to 30 and bins to 6. For HTF raise window to 100 and bins to 12.

[b]Originality / what's reused[/b]

Shannon entropy is textbook 1948 information theory — public domain. The implementation here — the rolling N-return histogram pipeline with configurable bins, the log(B)-normalised entropy formula, the two-threshold regime classifier with mixed centre, the slope-coloured entropy line, the chart-overlay bar-colouring projection from the pane, and the user-configurable Suggested JOAT Indicator dashboard row — is JOAT-original. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The histogram + entropy loop, the regime classifier, the slope-colour pipeline, and the dashboard are isolated modules. Forks welcome with credit.

[b]Limitations[/b]

Shannon entropy describes the recent distribution of returns — it does not predict direction. A directional regime tells you momentum tools should work; it does not say which way. The histogram is sensitive to bin count and window length; the rule-of-thumb window / bins ≥ 5 is the default sanity check. EMA smoothing trades some lag for substantially reduced flicker; turn smoothing to 1 to see raw entropy.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Entropy Oscillator [JOAT]",
     shorttitle="ENT [JOAT]",
     overlay=false,
     precision=4,
     max_lines_count=500,
     max_labels_count=500,
     max_boxes_count=500,
     max_bars_back=5000)

// =====================================================================================================================
//  SECTION 1 - INPUTS
// =====================================================================================================================

// ---- Group headers --------------------------------------------------------------------------------------------
gpCalc   = "+--------- CALCULATION ---------+"
gpThr    = "+--------- THRESHOLDS ----------+"
gpVis    = "+----------- VISUALS -----------+"
gpBar    = "+------ BAR COLORING (OVL) -----+"
gpDash   = "+----------- DASHBOARD ---------+"
gpSugg   = "+------ REGIME SUGGESTION ------+"
gpAlerts = "+------------ ALERTS -----------+"

// ---- Calc -----------------------------------------------------------------------------------------------------------
windowLen = input.int(50, "Rolling Window (N returns)", minval=10, maxval=400, step=5, group=gpCalc,
     tooltip="Number of log-return samples used to estimate the empirical distribution. Larger windows are smoother "
           + "but slower to react. Common range: 30-100 for swing, 100-200 for position.")
nBins     = input.int(10, "Distribution Bins (B)",      minval=4,  maxval=30,  step=1, group=gpCalc,
     tooltip="Number of equal-width bins. Higher resolution = more granular distribution but requires more samples to "
           + "be statistically meaningful. Rule of thumb: window / bins >= 5.")
smoothLen = input.int(3,  "Entropy Smoothing (EMA)",    minval=1,  maxval=20,  step=1, group=gpCalc,
     tooltip="Light EMA on the raw entropy series to suppress single-bar noise without lagging the regime view.")
srcInput  = input.source(close, "Return Source",        group=gpCalc,
     tooltip="Series used to compute log returns. Default close; ohlc4 is acceptable for noisier markets.")

// ---- Thresholds -----------------------------------------------------------------------------------------------------
lowTh   = input.float(0.30, "Low Entropy Threshold (Directional)",  minval=0.05, maxval=0.60, step=0.01, group=gpThr,
     tooltip="Normalised entropy below this value labels the regime as DIRECTIONAL. Spec default: 0.30.")
highTh  = input.float(0.70, "High Entropy Threshold (Chop)",        minval=0.40, maxval=0.95, step=0.01, group=gpThr,
     tooltip="Normalised entropy above this value labels the regime as CHOP. Spec default: 0.70.")

// ---- Visuals --------------------------------------------------------------------------------------------------------
showThrFills = input.bool(true,  "Show Threshold Zone Fills",          group=gpVis,
     tooltip="Fill the low and high zones with translucent regime colors.")
showThrLines = input.bool(true,  "Show Threshold Lines (hlines)",      group=gpVis,
     tooltip="Plot horizontal lines at the low/high thresholds and midpoint 0.5.")
showEntropy  = input.bool(true,  "Show Entropy Line (slope-coloured)", group=gpVis,
     tooltip="Plot the main entropy line with slope-based gradient color (bull color when entropy is falling toward "
           + "directional, bear color when entropy is rising toward chop).")
showRegime   = input.bool(true,  "Show Regime Background Tint (pane)", group=gpVis,
     tooltip="Tint the pane background by current regime: cool tint for directional, hot tint for chop, neutral mid.")
gradInt      = input.int(75,     "Fill Transparency (0=opaque,100=invisible)", minval=40, maxval=98, group=gpVis)
slopeLen     = input.int(5,      "Slope Smoothing Window",              minval=2, maxval=30, group=gpVis,
     tooltip="EMA length used to normalise the entropy slope for line gradient coloring.")

// ---- Bar Coloring (Overlay on chart) --------------------------------------------------------------------------------
barColorActive = input.bool(false, "Bar Coloring on Chart Overlay", group=gpBar,
     tooltip="When ON, chart bars are tinted by regime: cool when directional, hot when chop, neutral when mixed. "
           + "Uses Pine's barcolor() which projects from a pane indicator onto the price chart.")
overlayBg      = input.bool(false, "Overlay Regime Background (chart)", group=gpBar,
     tooltip="When ON, projects a subtle bgcolor onto the main chart marking the current regime. Uses force_overlay.")
barColorAlpha  = input.int(0,  "Bar Color Alpha (0=opaque)", minval=0, maxval=80, group=gpBar)

// ---- Dashboard ------------------------------------------------------------------------------------------------------
showDash  = input.bool(true, "Show Dashboard", group=gpDash)
dashPos   = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"],
     group=gpDash)
dashSize  = input.string("Small", "Dashboard Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=gpDash)

// ---- Regime Suggestion ----------------------------------------------------------------------------------------------
showSugg  = input.bool(true, "Suggest a JOAT Indicator for Current Regime", group=gpSugg,
     tooltip="The dashboard will display a recommended companion JOAT indicator based on the current entropy regime.")
sugDir    = input.string("AlphaTrend [JOAT]",          "Suggested Indicator (Directional)",
     options=["AlphaTrend [JOAT]","Kalman Quantum Drift [JOAT]","Hurst Regime Sentinel [JOAT]","Doppler Velocity Shift [JOAT]","Buy Sell Regression [JOAT]"],
     group=gpSugg)
sugChop   = input.string("Z-Score Reversion [JOAT]",   "Suggested Indicator (Chop)",
     options=["Z-Score Reversion [JOAT]","Heisenberg Uncertainty Bands [JOAT]","Brownian Motion Residual [JOAT]","Mean Reversion Pro [JOAT]","Renaissance Mean Reversion [JOAT]"],
     group=gpSugg)
sugMid    = input.string("Liquidity Magnet [JOAT]",    "Suggested Indicator (Mixed)",
     options=["Liquidity Magnet [JOAT]","Support & Resistance [JOAT]","SMC Quant Framework [JOAT]","Schrodinger Zone Probability [JOAT]","Fractal Dimension Index [JOAT]"],
     group=gpSugg)

// ---- Alerts ---------------------------------------------------------------------------------------------------------
alertOnLow     = input.bool(true, "Alert: Cross into Low Entropy (Directional)",  group=gpAlerts)
alertOnHigh    = input.bool(true, "Alert: Cross into High Entropy (Chop)",        group=gpAlerts)
alertOnRegime  = input.bool(true, "Alert: Any Regime Change",                     group=gpAlerts)


// =====================================================================================================================
//  SECTION 2 - COLOR PALETTE  (Crimson Pulse - curated)
//      Directional = rgb(0,207,254) (electric blue)
//      Chop        = #e0f70e (lime-yellow)
//      Mixed       = #9E7680 (muted mauve)
//      BG / Frame  = #12080C / #2A0F18
// ---------------------------------------------------------------------------------------------------------------------

const color C_BULL  = color.rgb(0, 207, 254)   // directional (low entropy / calm)
const color C_BEAR  = #e0f70e                   // chop (high entropy / chaos)
const color C_MID   = #9E7680                   // mixed (muted mauve)
const color C_BG    = #12080C
const color C_FRAME = #2A0F18
color C_TEXT        = color.new(#E6E6E6, 0)


// =====================================================================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =====================================================================================================================

// ---- 3.1 Linear-interpolation gradient between two colors (KB 2.1) -------------------------------------------------
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// ---- 3.2 Multi-stop gradient between three colors (cool -> mid -> hot) ---------------------------------------------
f_triGradient(float _ratio, color _cool, color _mid, color _hot) =>
    r = _ratio < 0.5 ? f_colorGradient(_ratio * 2.0, _cool, _mid) : f_colorGradient((_ratio - 0.5) * 2.0, _mid, _hot)
    r

// ---- 3.3 Clamp helper (KB 2.3) -------------------------------------------------------------------------------------
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// ---- 3.4 Position-string resolver (KB 2.4) -------------------------------------------------------------------------
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// ---- 3.5 Size-string resolver --------------------------------------------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ---- 3.6 Row gradient background helper (KB 2.5) -------------------------------------------------------------------
grad(color _base, int _row, int _rows, int _minT, int _maxT) =>
    float t = _rows <= 1 ? float(_minT) : (_minT + (_maxT - _minT) * (_row / float(_rows - 1)))
    color.new(_base, int(t))

// ---- 3.7 Regime classifier -----------------------------------------------------------------------------------------
//      Returns: -1 = Directional (low entropy), 0 = Mixed, +1 = Chop (high entropy)
f_classify(float _h, float _lo, float _hi) =>
    r = na(_h) ? 0 : _h < _lo ? -1 : _h > _hi ? 1 : 0
    r

// ---- 3.8 Regime name -----------------------------------------------------------------------------------------------
f_regimeName(int _r) =>
    string s = _r == -1 ? "Directional" : _r == 1 ? "Chop" : "Mixed"
    s

// ---- 3.9 Suggested indicator resolver ------------------------------------------------------------------------------
f_suggest(int _r, string _sDir, string _sChop, string _sMid) =>
    string s = _r == -1 ? _sDir : _r == 1 ? _sChop : _sMid
    s

// ---- 3.10 Regime color ---------------------------------------------------------------------------------------------
f_regimeColor(int _r, color _dir, color _chop, color _mid) =>
    color c = _r == -1 ? _dir : _r == 1 ? _chop : _mid
    c

// ---- 3.11 Format float with fixed precision ------------------------------------------------------------------------
f_fmt(float _x, int _prec) =>
    string s = na(_x) ? "n/a" : str.tostring(_x, "#." + str.repeat("#", _prec))
    s

// ---- 3.12 Format integer with sign ---------------------------------------------------------------------------------
f_signedBars(int _n) =>
    string s = _n <= 0 ? "now" : str.tostring(_n) + " bars ago"
    s


// =====================================================================================================================
//  SECTION 4 - CORE CALCULATION  (Shannon entropy over rolling log-return distribution)
// =====================================================================================================================
//
//  Steps:
//      1. Compute log return ret_t  = math.log(src_t / src_{t-1}).
//      2. Maintain a rolling buffer of the last `windowLen` returns. We use Pine's history operator + a fresh array
//         each bar (cheap because windowLen <= 400 and nBins <= 30).
//      3. Find rMin, rMax across the window. Guard against degenerate windows (all-zero or NaN).
//      4. Width      = (rMax - rMin) / nBins.
//      5. For each return, index = clamp(floor((ret - rMin) / width), 0, nBins-1). Increment count[index].
//      6. Probabilities p_i = count_i / N for nonzero bins. H = - sum p_i * ln(p_i).
//      7. Hmax = ln(nBins). H_n = H / Hmax in [0, 1]. Light EMA smoothing.
// ---------------------------------------------------------------------------------------------------------------------

// 4.1 -- Log return series ------------------------------------------------------------------------------------------
float rawRet = na(srcInput[1]) or srcInput[1] <= 0.0 or srcInput <= 0.0 ? na : math.log(srcInput / srcInput[1])

// 4.2 -- Entropy computation function (pure function, called once per bar) ------------------------------------------
//      Inputs:  windowLen, nBins
//      Returns: normalized entropy H_n in [0, 1], or na while warming up
f_shannonEntropy(int _winLen, int _bins) =>
    float H_norm = na
    if bar_index >= _winLen + 1
        // ---- collect returns into a temporary float array
        var array<float> rets = array.new_float(0)
        rets.clear()
        rMin = math.log(1.0)   // 0.0; sentinel reinit
        rMax = math.log(1.0)
        bool initd = false
        for i = 0 to _winLen - 1
            float r = rawRet[i]
            if not na(r)
                rets.push(r)
                if not initd
                    rMin := r
                    rMax := r
                    initd := true
                else
                    if r < rMin
                        rMin := r
                    if r > rMax
                        rMax := r
        int n = rets.size()
        // ---- guards: need enough valid samples and non-degenerate range
        if n >= int(math.max(8, _winLen * 0.5)) and rMax > rMin
            float width = (rMax - rMin) / float(_bins)
            if width > 0.0
                var array<int> counts = array.new_int(0)
                counts.clear()
                for b = 0 to _bins - 1
                    counts.push(0)
                // ---- bin assignment
                for i = 0 to n - 1
                    float r = rets.get(i)
                    int idx = int(math.floor((r - rMin) / width))
                    idx := math.max(0, math.min(_bins - 1, idx))
                    counts.set(idx, counts.get(idx) + 1)
                // ---- Shannon entropy
                float H = 0.0
                float invN = 1.0 / float(n)
                for b = 0 to _bins - 1
                    int c = counts.get(b)
                    if c > 0
                        float p = float(c) * invN
                        H := H - p * math.log(p)
                float Hmax = math.log(float(_bins))
                if Hmax > 0.0
                    H_norm := H / Hmax
    H_norm

// 4.3 -- Raw and smoothed entropy series ----------------------------------------------------------------------------
float entropyRaw    = f_shannonEntropy(windowLen, nBins)
float entropy       = na(entropyRaw) ? na : ta.ema(entropyRaw, smoothLen)
float entropyClamp  = na(entropy) ? na : f_clamp(entropy, 0.0, 1.0)

// 4.4 -- Slope of entropy (for line gradient) -----------------------------------------------------------------------
float slopeRaw    = nz(entropy - entropy[1], 0.0)
float slopeAbs    = ta.ema(math.abs(slopeRaw), slopeLen)
float slopeNorm   = slopeAbs > 0.0 ? slopeRaw / slopeAbs : 0.0
float slopeSmooth = ta.ema(slopeNorm, slopeLen)
//      Map slope to a 0..1 ratio: -1 (falling toward directional) -> 0 (bull), +1 (rising toward chop) -> 1 (bear).
float lineRatio   = f_clamp(0.5 + slopeSmooth / 2.0, 0.0, 1.0)


// =====================================================================================================================
//  SECTION 5 - STATE / TRACKING  (regime variables + change history)
// =====================================================================================================================

var int   currentRegime    = 0
var int   prevRegime       = 0
var int   lastRegimeBar    = na
var int   lastDirectional  = na
var int   lastChop         = na
var int   lastMixed        = na
var float lastEntropyOnChg = na
var int   nRegimeChanges   = 0
var int   totalDirBars     = 0
var int   totalChopBars    = 0
var int   totalMixedBars   = 0

// 5.1 -- Update on confirmed bars only (KB 6.3) ---------------------------------------------------------------------
if barstate.isconfirmed and not na(entropy)
    newRegime = f_classify(entropy, lowTh, highTh)
    if newRegime != currentRegime
        prevRegime       := currentRegime
        currentRegime    := newRegime
        lastRegimeBar    := bar_index
        lastEntropyOnChg := entropy
        nRegimeChanges   += 1
    if currentRegime == -1
        lastDirectional := bar_index
        totalDirBars    += 1
    else if currentRegime == 1
        lastChop        := bar_index
        totalChopBars   += 1
    else
        lastMixed       := bar_index
        totalMixedBars  += 1


// =====================================================================================================================
//  SECTION 6 - SIGNAL ENGINE  (cooldown + cross detection)
// =====================================================================================================================

// 6.1 -- Cooldown gap so we don't fire dozens of times in a chop sequence ------------------------------------------
var int lastAlertBar = -1000
int signalGap = 3
canTrigger = bar_index - lastAlertBar >= signalGap

// 6.2 -- Cross-detection on smoothed entropy -----------------------------------------------------------------------
bool crossInLow  = not na(entropy) and not na(entropy[1]) and entropy < lowTh  and entropy[1] >= lowTh
bool crossInHigh = not na(entropy) and not na(entropy[1]) and entropy > highTh and entropy[1] <= highTh
bool regimeShift = currentRegime != prevRegime and not na(lastRegimeBar) and lastRegimeBar == bar_index

if (crossInLow or crossInHigh or regimeShift) and canTrigger
    lastAlertBar := bar_index


// =====================================================================================================================
//  SECTION 7 - PLOTS / FILLS  (entropy line, threshold lines, zone fills, slope gradient)
// =====================================================================================================================

// 7.1 -- Threshold lines (hidden when toggled off) -----------------------------------------------------------------
pLow  = plot(showThrLines ? lowTh : na, "Low Th",  color=color.new(C_BULL, 25), linewidth=1, style=plot.style_linebr)
pHigh = plot(showThrLines ? highTh : na, "High Th", color=color.new(C_BEAR, 25), linewidth=1, style=plot.style_linebr)
pMid  = plot(showThrLines ? 0.5 : na,   "Mid",     color=color.new(C_MID,  40), linewidth=1, style=plot.style_linebr)
plot(showThrLines ? 1.0 : na, "Hmax",  color=color.new(C_MID,  85), linewidth=1, style=plot.style_linebr)
pZero = plot(showThrLines ? 0.0 : na,   "Floor",   color=color.new(C_MID,  85), linewidth=1, style=plot.style_linebr)

// 7.2 -- Zone fills (low / high regime tints) ----------------------------------------------------------------------
fill(pZero, pLow,  color=showThrFills ? color.new(C_BULL, gradInt + 6) : na, title="Directional Zone")
fill(pHigh, pMid,  color=showThrFills ? color.new(C_BEAR, gradInt + 6) : na, title="Chop Zone")

// 7.3 -- Slope-colored entropy line -------------------------------------------------------------------------------
//      The line color is interpolated along (bull, mid, bear) by the normalized slope ratio.
color lineCol = f_triGradient(lineRatio, C_BULL, C_MID, C_BEAR)
plot(showEntropy ? entropyClamp : na, "Entropy H_n", color=lineCol, linewidth=2)

// 7.4 -- Halo / ghost trace (subtle wider line behind) -------------------------------------------------------------
plot(showEntropy ? entropyClamp : na, "Entropy Halo", color=color.new(lineCol, 70), linewidth=4)

// 7.5 -- Optional shading of the area between the line and 0.5 mid -------------------------------------------------
//      Useful for visually emphasising "how far above / below center" the entropy is.
midSeries = plot(0.5, "Mid Ref", color=na, display=display.none)
entSeries = plot(showEntropy ? entropyClamp : na, "Entropy Anchor", color=na, display=display.none)
fillCol   = na(entropy) ? na : entropy > 0.5 ? color.new(C_BEAR, gradInt + 8) : color.new(C_BULL, gradInt + 8)
fill(midSeries, entSeries, color=fillCol, title="Mid/Line Fill")

// 7.6 -- Regime background tint (pane) -----------------------------------------------------------------------------
color regTint = na
if showRegime
    regTint := currentRegime == -1 ? color.new(C_BULL, 92) : currentRegime ==  1 ? color.new(C_BEAR, 92) : color.new(C_MID,  95)
bgcolor(regTint, title="Pane Regime Tint")

// 7.7 -- Overlay background tint on chart (force_overlay) ----------------------------------------------------------
color regTintOvl = na
if overlayBg
    regTintOvl := currentRegime == -1 ? color.new(C_BULL, 94) : currentRegime ==  1 ? color.new(C_BEAR, 94) : color.new(C_MID,  96)
bgcolor(regTintOvl, title="Chart Regime Tint (overlay)", force_overlay=true)


// =====================================================================================================================
//  SECTION 8 - BAR COLORING ON CHART OVERLAY
// =====================================================================================================================
//
//  barcolor() called from a pane indicator paints the MAIN CHART bars (KB 11 + snapshot confirmation).
//  We emit only when barColorActive is true; otherwise we pass `na` so the user's native candle colors are preserved.
// ---------------------------------------------------------------------------------------------------------------------

color barTint = na
if barColorActive and not na(entropy)
    barTint := currentRegime == -1 ? color.new(C_BULL, barColorAlpha) : currentRegime ==  1 ? color.new(C_BEAR, barColorAlpha) : color.new(C_MID,  barColorAlpha + 5)
barcolor(barTint, title="Regime Bar Coloring (chart)")


// =====================================================================================================================
//  SECTION 9 - DASHBOARD (7 substantive rows + header per spec)
// =====================================================================================================================
//
//  Rows:
//      0 Header (spans 2 cols): "ENTROPY OSCILLATOR"
//      1 Current Entropy
//      2 Regime (Directional / Mixed / Chop)
//      3 Bins setting
//      4 Window setting
//      5 Last regime change (n bars ago)
//      6 Suggested JOAT indicator for regime
//      7 Bar coloring active?
// ---------------------------------------------------------------------------------------------------------------------

var table dashTbl = na
if showDash and barstate.islast
    dashTbl := table.new(strToPos(dashPos), 2, 8,
         bgcolor      = color.new(C_BG, 12),
         frame_color  = C_FRAME,
         frame_width  = 1,
         border_color = color.new(C_FRAME, 60),
         border_width = 1)

if showDash and barstate.islast and not na(dashTbl)
    // Row 0 - Header spans both columns (we use two cells with shared style for compatibility)
    table.cell(dashTbl, 0, 0, "ENTROPY OSCILLATOR",
         text_color=C_TEXT, bgcolor=grad(C_FRAME, 0, 8, 30, 40),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 0, "[JOAT]",
         text_color=C_TEXT, bgcolor=grad(C_FRAME, 0, 8, 30, 40),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 1 - Current entropy value
    string entStr = na(entropy) ? "warming up" : f_fmt(entropyClamp, 4)
    entVal = na(entropy) ? color.new(C_MID, 0) : entropy < lowTh ? C_BULL : entropy > highTh ? C_BEAR : C_MID
    table.cell(dashTbl, 0, 1, "Entropy H_n",
         text_color=C_TEXT, bgcolor=grad(C_BG, 1, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 1, entStr,
         text_color=entVal, bgcolor=grad(C_BG, 1, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 2 - Regime
    string regStr = f_regimeName(currentRegime)
    color  regCol = f_regimeColor(currentRegime, C_BULL, C_BEAR, C_MID)
    table.cell(dashTbl, 0, 2, "Regime",
         text_color=C_TEXT, bgcolor=grad(C_BG, 2, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 2, regStr,
         text_color=regCol, bgcolor=grad(C_BG, 2, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 3 - Bins setting
    table.cell(dashTbl, 0, 3, "Bins (B)",
         text_color=C_TEXT, bgcolor=grad(C_BG, 3, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 3, str.tostring(nBins),
         text_color=C_TEXT, bgcolor=grad(C_BG, 3, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 4 - Window setting
    table.cell(dashTbl, 0, 4, "Window (N)",
         text_color=C_TEXT, bgcolor=grad(C_BG, 4, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 4, str.tostring(windowLen),
         text_color=C_TEXT, bgcolor=grad(C_BG, 4, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 5 - Last regime change
    string chgStr = na(lastRegimeBar) ? "no shift yet" : f_signedBars(bar_index - lastRegimeBar)
    table.cell(dashTbl, 0, 5, "Last Regime Shift",
         text_color=C_TEXT, bgcolor=grad(C_BG, 5, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 5, chgStr,
         text_color=C_TEXT, bgcolor=grad(C_BG, 5, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 6 - Suggested companion JOAT indicator
    string sugStr = showSugg ? f_suggest(currentRegime, sugDir, sugChop, sugMid) : "disabled"
    color  sugCol = showSugg ? f_regimeColor(currentRegime, C_BULL, C_BEAR, C_MID) : C_MID
    table.cell(dashTbl, 0, 6, "Suggested JOAT",
         text_color=C_TEXT, bgcolor=grad(C_BG, 6, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 6, sugStr,
         text_color=sugCol, bgcolor=grad(C_BG, 6, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)

    // Row 7 - Bar coloring active flag
    string bcStr = barColorActive ? "ON  (regime tint)" : "OFF"
    color  bcCol = barColorActive ? C_BULL : C_MID
    table.cell(dashTbl, 0, 7, "Bar Coloring (chart)",
         text_color=C_TEXT, bgcolor=grad(C_BG, 7, 8, 78, 92),
         text_halign=text.align_left, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)
    table.cell(dashTbl, 1, 7, bcStr,
         text_color=bcCol, bgcolor=grad(C_BG, 7, 8, 78, 92),
         text_halign=text.align_right, text_size=strToSize(dashSize),
         text_font_family=font.family_monospace)


// =====================================================================================================================
//  SECTION 10 - ALERTS
// =====================================================================================================================
//
//  Three alert conditions exposed via Pine's standard alertcondition() so they appear in TradingView's alerts UI.
// ---------------------------------------------------------------------------------------------------------------------

alertcondition(alertOnLow    and crossInLow,
     title = "Entropy Cross Into Low (Directional)",
     message = "ENT [JOAT]: entropy crossed BELOW low threshold - DIRECTIONAL regime detected.")

alertcondition(alertOnHigh   and crossInHigh,
     title = "Entropy Cross Into High (Chop)",
     message = "ENT [JOAT]: entropy crossed ABOVE high threshold - CHOP regime detected.")

alertcondition(alertOnRegime and regimeShift,
     title = "Regime Change",
     message = "ENT [JOAT]: regime changed - reassess companion indicator selection.")


// =====================================================================================================================
//  END OF SCRIPT
// ---------------------------------------------------------------------------------------------------------------------
//  Notes on usage:
//    * The first `windowLen + 1` bars warm up silently; the line begins after enough returns accumulate.
//    * Crimson Pulse theme uses electric blue for "calm / directional" and lime-yellow for "chaotic / chop", which
//      matches the visual semantics of low/high entropy in the AlgoAlpha reference aesthetic.
//    * Pair with Hurst Regime Sentinel and Fractal Dimension Index for triple-confirmation regime detection - all
//      three should agree before flipping companion-indicator selection on a discretionary basis.
//    * `barcolor()` is called from a pane indicator (overlay=false) but TradingView projects it onto the main chart.
//    * `force_overlay = true` on the optional overlay bgcolor() pushes the regime tint to the chart pane as well.
// =====================================================================================================================
````
