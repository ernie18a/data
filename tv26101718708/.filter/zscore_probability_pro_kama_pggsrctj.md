# Z-Score Probability Pro KAMA

- url: https://www.tradingview.com/script/PggSrcTj-Z-Score-Probability-Pro-KAMA/
- type: indicator
- pine_id: PUB;2db5e7e91f3845af9f2c5eb684d8afb6
- version: 2.0

## Description

[image]https://www.tradingview.com/x/OqWiuPXM/[/image]

[b]Z-Score Probability Pro KAMA, v1.0 by Erika Barker[/b]

Hey guys, this is the successor to my original Z-Score Probability HMA Indicator, which you can still use if you prefer that one.

This is version 1.0 of the new rebuild, and it is a pretty big upgrade. The goal was to keep the statistical foundation that made the original useful, but make it more adaptive, cleaner, and better at understanding different market conditions.

[b]What is new[/b]

1. Timeframe auto-adaptation

No more constantly re-tuning the indicator when you switch charts.

The lookback now automatically adjusts based on the chart timeframe, using a calendar-style window, defaulting to about 5 trading days. The dashboard also shows the effective lookback being used, so you always know what the script is calculating from.

It works from 1 minute charts all the way up to weekly charts.

2. Better smoothing logic

The original HMA was doing a lot of work at once. In this version, the baseline and the Z-score smoothing are separated so each one can do its own job better.

By default:

* Baseline: KAMA, great for adapting to noisy markets
* Z-score smoothing: ALMA, smoother and cleaner on the oscillator

HMA is still available if you prefer the original feel.

3. Modified Z-Score option

There is now an optional Modified Z-Score mode using MAD, median absolute deviation.

This is useful for markets with big outliers, fat tails, sudden spikes, crypto moves, small caps, and anything that tends to behave a little wild.

When this mode is turned on, the threshold bands automatically adjust.

4. Regime filter using Hurst logic (been needing out on this a lot lately on personal stuff)

This version attempts to classify the market as:

* Trending
* Mean-reverting
* Random

That matters because an extreme Z-score does not always mean the same thing.

In a mean-reverting market, an extreme Z-score can suggest exhaustion.

In a trending market, that same extreme can sometimes mean continuation or breakout strength.

This was one of the biggest things I wanted to improve from the original.

5. Divergence engine

The indicator now includes both regular and hidden divergence.

It can detect:

* Regular bullish divergence
* Regular bearish divergence
* Hidden bullish divergence
* Hidden bearish divergence

Divergences are confirmed using pivots, so they are non-repainting, but they will appear a few bars after the actual pivot. That is the tradeoff for confirmation.

6. Higher-timeframe confirmation

The script can pull Z-score confirmation from a higher timeframe.

You can use the automatic HTF mode or set it manually. HTF values only update after the higher-timeframe candle closes, so this is designed to avoid repainting.

7. Strong Buy and Strong Sell signals

Signals are based on a confluence score instead of just one condition.

The score looks at things like:

* Z-score reversal
* Divergence
* Baseline slope
* Market regime
* Higher-timeframe agreement
* Volume confirmation, when volume is available

You can choose the conviction level:

* Low
* Medium
* High

Medium is the default and should give fewer, cleaner signals.

8. Live dashboard

The dashboard shows:

* Detected timeframe
* Effective lookback
* Current Z-score
* Market regime
* Hurst value
* Higher-timeframe status
* Bull and bear scores
* Conviction threshold
* Last signal

You can move it to any corner of the chart.

9. More stable defaults

The defaults were chosen to be centered in stable performance zones, not over-optimized for one market.

Basically, I did not want this to be something that only looks good on one ticker, one timeframe, during one perfect backtest window.

10. Built in Pine v6

This version uses Pine v6 features, including dynamic higher-timeframe requests and confirmed-bar alert logic.

Repaint disclosure

This indicator is designed to avoid repainting, but there are a few things to know:

* Divergence and Strong Buy/Sell labels appear after pivot confirmation, default is 3 bars later
* Higher-timeframe confirmation only updates after the higher-timeframe candle closes
* Alerts fire on confirmed bars, not intrabar ticks

So, signals are delayed slightly by design, but that is what makes them confirmed.

How to use it

Beginner

Leave everything on default.

Watch the dashboard and look for:

* Strong Buy
* Strong Sell

Medium conviction is probably the best starting point.

Intermediate

Try the Modified Z-Score mode on crypto, small caps, or anything with sharp moves and big outliers.

Turn on Hidden Divergence if you like trading trend continuation setups.

Advanced

You can tune the component weights to match your own strategy.

The indicator is flexible, so you can make it more reversal-focused, more trend-following, or more confirmation-heavy depending on your trading style.

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                                                              ║
// ║  Z-SCORE PROBABILITY PRO KAMA (v1.1)                                         ║
// ║  Original: "Z-Score Probability HMA " by Erika Barker                        ║
// ║  Community release upgrade — free, open source                               ║
// ║                                                                              ║
// ║  ─── WHAT'S NEW IN v3 ─────────────────────────────────────────────────────  ║
// ║    1.  Timeframe-adaptive lookback (calendar-equivalent windows)             ║
// ║          → No more re-tuning when you switch from 5m to 1H to Daily          ║
// ║    2.  Smoother stack: KAMA baseline (Kaufman 1998) + ALMA / HMA on Z        ║
// ║          → KAMA's efficiency ratio self-attenuates in noise                  ║
// ║    3.  Robust Modified Z-Score option (Iglewicz & Hoaglin 1993, MAD-based)   ║
// ║          → Survives fat tails and outliers that break classical Z            ║
// ║    4.  Hurst-exponent regime filter (variance-ratio shortcut)                ║
// ║          → Switches signal logic between exhaustion (mean-revert)            ║
// ║            and ignition (trending) regimes                                   ║
// ║    5.  Divergence engine: regular + hidden, zone-filtered, non-repainting    ║
// ║    6.  Higher-timeframe confirmation via dynamic request.security            ║
// ║    7.  Weighted confluence scoring (0–100) → Strong Buy / Strong Sell        ║
// ║          → 6 components: Z reversal, divergence, slope, regime, HTF, volume  ║
// ║          → Conviction selector: Low / Medium / High                          ║
// ║    8.  Live dashboard: detected TF, effective lookback, regime, score        ║
// ║    9.  Plateau-centered defaults justified by published literature           ║
// ║   10.  v6 features used: dynamic security, UDTs, lookahead_off, methods      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

indicator("Z-Score Probability Pro", shorttitle="Z-Pro",
     overlay=false,
     max_lines_count=300,
     max_labels_count=300,
     max_bars_back=500)


// ═══════════════════════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
SEC_PER_DAY     = 86400.0
EPS             = 1e-10
MAD_K           = 0.6745   // Iglewicz & Hoaglin scaling constant


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 1: Core Settings
// ═══════════════════════════════════════════════════════════════════════════════
coreGroup = "① Core Settings"

autoTuneByTF    = input.bool(true, "Auto-Tune by Timeframe", group=coreGroup,
     tooltip="When enabled, the script automatically picks the best baseline / smoother / Z-source / conviction per chart TF — overriding the dropdowns in Section ②. Profiles derived from Optuna IC tuning across ~60 US equities (2023–2025). Disable to use manual settings from the dropdowns.")

autoAdaptTF     = input.bool(true, "Auto-Adapt Lookback to Timeframe", group=coreGroup,
     tooltip="When enabled, lookback period auto-scales to ~5 trading days of bars (or your target days below). Disable to use the fixed length.")

targetDays      = input.float(5.0, "Target Calendar Window (days)", minval=1.0, maxval=30.0, step=0.5, group=coreGroup,
     tooltip="Calendar-equivalent window the lookback should approximate. Plateau-tested range from mean-reversion literature: 3-10 days for equities, 5-14 for crypto. Default 5. (Overridden when Auto-Tune by TF is enabled.)")

fixedLength     = input.int(75, "Fixed Lookback (if auto-adapt off)", minval=10, maxval=500, group=coreGroup,
     tooltip="Used only when Auto-Adapt is disabled. Original v1 default was 75.")

minLookback     = input.int(20, "Minimum Adapted Lookback", minval=10, maxval=100, group=coreGroup,
     tooltip="Floor for auto-adaptation. Below ~20 the Z-score becomes statistically unstable.")

maxLookback     = input.int(200, "Maximum Adapted Lookback", minval=50, maxval=500, group=coreGroup,
     tooltip="Ceiling for auto-adaptation. Above ~200 you lose responsiveness to regime shifts.")


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 2: Z-Score Method   (ignored when Auto-Tune by TF is on)
// ═══════════════════════════════════════════════════════════════════════════════
zGroup = "② Z-Score Method"

zMethod         = input.string("Classical", "Z-Score Method",
     options=["Classical", "Modified (MAD)"], group=zGroup,
     tooltip="Classical uses mean ± stdev. Modified uses median ± MAD with the 0.6745 Iglewicz constant — more robust to fat tails and outliers (financial returns are typically Student-t, df 3–5). (Overridden by Auto-Tune by TF.)")

zSource         = input.string("Price − Baseline", "Source",
     options=["Price − Baseline", "Pct Deviation", "Log Return"], group=zGroup,
     tooltip="Price − Baseline: classical residual.  Pct: (price-baseline)/baseline, stable across price levels.  Log Return: log(price/baseline), most statistically clean. (Overridden by Auto-Tune by TF.)")

baselineType    = input.string("KAMA", "Baseline Smoother",
     options=["KAMA", "HMA", "EMA", "ALMA"], group=zGroup,
     tooltip="KAMA (Kaufman) is recommended — its efficiency ratio self-attenuates in noise. HMA preserves the original v1 behavior. ALMA = Gaussian-weighted. (Overridden by Auto-Tune by TF.)")

zSmoother       = input.string("ALMA", "Z-Score Line Smoother",
     options=["ALMA", "HMA", "EMA", "None"], group=zGroup,
     tooltip="Smoothing applied to the Z-score output line itself. ALMA produces less ringing than HMA on the oscillator. Choose None to see raw Z. (Overridden by Auto-Tune by TF.)")

zSmoothLen      = input.int(9, "Z Smoothing Length", minval=1, maxval=50, group=zGroup,
     tooltip="Length of the Z-score line smoother. 9 is ALMA's classic default (Legoux).")


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 3: Signals & Confluence
// ═══════════════════════════════════════════════════════════════════════════════
sigGroup = "③ Signals & Confluence"

showSignals     = input.bool(true, "Show Strong Buy/Sell Signals", group=sigGroup)

conviction      = input.string("Medium", "Signal Conviction",
     options=["Low", "Medium", "High"], group=sigGroup,
     tooltip="Threshold for emitting a Strong signal.  Low ≥ 50 (≈daily, noisier).  Medium ≥ 65 (≈few per week, balanced).  High ≥ 80 (≈few per month, high precision). (Overridden by Auto-Tune by TF.)")

useDivergence   = input.bool(true, "Enable Divergence Detection", group=sigGroup)
useHurst        = input.bool(true, "Enable Hurst Regime Filter", group=sigGroup)
useHTF          = input.bool(true, "Enable HTF Confirmation", group=sigGroup)
useVolume       = input.bool(true, "Enable Volume Confirmation", group=sigGroup,
     tooltip="Skipped automatically on instruments without volume (FX, indices).")

// Component weights — exposed so users can tune, but defaults sum to 100
w_zReversal     = input.int(25, "Weight: Z Extreme Reversal", minval=0, maxval=50, group=sigGroup, inline="w1")
w_divergence    = input.int(25, "Weight: Divergence",         minval=0, maxval=50, group=sigGroup, inline="w2")
w_slope         = input.int(15, "Weight: Baseline Slope",     minval=0, maxval=50, group=sigGroup, inline="w3")
w_regime        = input.int(15, "Weight: Regime Agreement",   minval=0, maxval=50, group=sigGroup, inline="w4")
w_htf           = input.int(10, "Weight: HTF Agreement",      minval=0, maxval=50, group=sigGroup, inline="w5")
w_volume        = input.int(10, "Weight: Volume Confirm",     minval=0, maxval=50, group=sigGroup, inline="w6")


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 4: Divergence
// ═══════════════════════════════════════════════════════════════════════════════
divGroup = "④ Divergence"

showRegularDiv  = input.bool(true, "Show Regular Divergence",  group=divGroup,
     tooltip="Bull: price LL + Z HL (oversold reversal).  Bear: price HH + Z LH (overbought reversal).")

showHiddenDiv   = input.bool(false, "Show Hidden Divergence",  group=divGroup,
     tooltip="Bull: price HL + Z LL (continuation in uptrend).  Bear: price LH + Z HH (continuation in downtrend). High accuracy in strong trends — pair with Hurst > 0.55.")

pivotLeft       = input.int(5, "Pivot Left Lookback",  minval=2, maxval=20, group=divGroup)
pivotRight      = input.int(3, "Pivot Right Lookback", minval=1, maxval=10, group=divGroup,
     tooltip="Signals appear THIS many bars after the actual pivot (non-repainting cost).")

divZoneFilter   = input.bool(true, "Filter by Oversold/Overbought Zones", group=divGroup,
     tooltip="Only show regular bullish divergence when Z < -1.5, bearish when Z > 1.5. Reduces false signals by ~60% (supa.is RSI tutorial benchmark).")

divMaxBars      = input.int(60, "Max Bars Between Pivots", minval=10, maxval=200, group=divGroup)


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 5: Regime (Hurst)
// ═══════════════════════════════════════════════════════════════════════════════
regimeGroup = "⑤ Hurst Regime Filter"

hurstLen        = input.int(100, "Hurst Lookback", minval=30, maxval=300, group=regimeGroup,
     tooltip="Window for variance calculations. 100 is the QuantAlgo / PhenLabs convention.")

hurstLag        = input.int(10, "Hurst Lag", minval=2, maxval=50, group=regimeGroup,
     tooltip="Step size for the variance ratio. Larger = smoother regime classification.")

hurstSmooth     = input.int(5, "Hurst EMA Smoothing", minval=1, maxval=30, group=regimeGroup)

hurstTrendThr   = input.float(0.55, "Trending Threshold (H >)", minval=0.50, maxval=0.70, step=0.01, group=regimeGroup)
hurstRevertThr  = input.float(0.45, "Mean-Revert Threshold (H <)", minval=0.30, maxval=0.50, step=0.01, group=regimeGroup)


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 6: Higher Timeframe
// ═══════════════════════════════════════════════════════════════════════════════
htfGroup = "⑥ Higher Timeframe"

htfMode         = input.string("Auto (4×)", "HTF Mode",
     options=["Auto (4×)", "Auto (6×)", "Manual"], group=htfGroup,
     tooltip="Auto modes compute the higher timeframe from your chart TF. Manual lets you specify directly.")

htfManual       = input.timeframe("240", "Manual HTF", group=htfGroup,
     tooltip="Used only when HTF Mode = Manual.")


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS  —  Section 7: Display
// ═══════════════════════════════════════════════════════════════════════════════
dispGroup = "⑦ Display"

theme           = input.string("Carbon Dark", "Theme",
     options=["Carbon Dark", "Bloomberg Amber", "Custom"], group=dispGroup,
     tooltip="Carbon Dark: cyan/coral on near-black, IBM-style. Bloomberg Amber: monochrome amber terminal aesthetic. Custom: use the color pickers below.")

plotStyle       = input.string("Area", "Plot Style",
     options=["Area", "Candles", "Line"], group=dispGroup)

showZones       = input.bool(false, "Show Filled Zones", group=dispGroup,
     tooltip="Off by default. The graduated reference lines convey the same information with far less visual noise. Toggle on if you prefer the classic look.")

showDashboard   = input.bool(true, "Show Dashboard", group=dispGroup)
showZTable      = input.bool(false, "Show Probability Table", group=dispGroup)

// Custom colors (only used when theme = Custom)
cBullCustom     = input.color(color.rgb(8, 189, 186),  "Bull",     inline="c1", group=dispGroup)
cBearCustom     = input.color(color.rgb(250, 77, 86),  "Bear",     inline="c1", group=dispGroup)
cCritCustom     = input.color(color.rgb(241, 194, 27), "Critical", inline="c2", group=dispGroup)
cNeutralCustom  = input.color(color.rgb(141, 141, 141),"Neutral",  inline="c2", group=dispGroup)

dashPos         = input.string("Top Right", "Dashboard Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group=dispGroup)

dashSize        = input.string("Normal", "Dashboard Size",
     options=["Small", "Normal", "Large"], group=dispGroup)


// ═══════════════════════════════════════════════════════════════════════════════
//  THEME RESOLUTION  —  three semantic accents, monochromatic substrate
// ═══════════════════════════════════════════════════════════════════════════════
bullColor    = theme == "Bloomberg Amber" ? color.rgb(255, 176, 0) :
               theme == "Custom"          ? cBullCustom :
               color.rgb(8, 189, 186)
bearColor    = theme == "Bloomberg Amber" ? color.rgb(255, 100, 100) :
               theme == "Custom"          ? cBearCustom :
               color.rgb(250, 77, 86)
critColor    = theme == "Bloomberg Amber" ? color.rgb(255, 220, 100) :
               theme == "Custom"          ? cCritCustom :
               color.rgb(241, 194, 27)
neutralColor = theme == "Custom" ? cNeutralCustom : color.rgb(141, 141, 141)

chromeBg     = color.rgb(22, 22, 22)
chromeBorder = color.rgb(57, 57, 57)
chromeDivide = color.rgb(38, 38, 38)
textPrimary  = color.rgb(244, 244, 244)
textMuted    = color.rgb(141, 141, 141)
textDim      = color.rgb(82, 82, 82)

warnColor    = critColor


// ═══════════════════════════════════════════════════════════════════════════════
//  AUTO-TUNED PROFILES BY TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════════
// Derived from Optuna IC tuning across ~60 US equities (2023–2025) with held-out
// random-symbol test split. Profiles maximize the wave's predictive power
// (Spearman rank correlation between Z and forward N-bar return).
//
//   secPerBar buckets  →  tuned profile
//   ≥ 86400 (1d+)      →  KAMA / Classical / Pct Dev / None     / Medium  (5d target)
//   ≥ 14400 (4h)       →  EMA  / Classical / Pct Dev / EMA      / High    (17d target)
//   ≥  7200 (2h)       →  EMA  / Classical / Price-B / None     / Medium  (16d target)
//   ≥  3600 (1h)       →  EMA  / Classical / Log Ret / HMA      / Medium  (16d target)
//   ≥  1800 (30m)      →  EMA  / Classical / Pct Dev / HMA      / Medium  (18d target)
//   ≥   900 (15m)      →  EMA  / Classical / Price-B / None     / Medium  (10d target)
//   ≥   300 (5m)       →  HMA  / Classical / Price-B / None     / Medium  (13d target)
//   <   300 (1m)       →  KAMA / Classical / Price-B / None     / Low     (17d target)
//
// Notable finding: EMA baseline beat KAMA on 6 of 8 TFs despite this being the
// "KAMA edition." zMethod Classical wins universally. The wave is genuinely
// predictive on daily (IC ≈ -0.07); intraday is weaker but tuning gives 3-11×
// improvement over the original defaults.

secPerBar       = timeframe.in_seconds()
secPerBarChk    = math.max(secPerBar, 60)

// TF-resolved profile (used when autoTuneByTF is on)
profTargetDays  = secPerBarChk >= 86400 ?  5.0 :
                  secPerBarChk >= 14400 ? 17.0 :
                  secPerBarChk >=  7200 ? 16.0 :
                  secPerBarChk >=  3600 ? 16.0 :
                  secPerBarChk >=  1800 ? 18.0 :
                  secPerBarChk >=   900 ? 10.0 :
                  secPerBarChk >=   300 ? 13.0 :
                                          17.0

profBaseline    = secPerBarChk >= 86400 ? "KAMA" :
                  secPerBarChk >= 14400 ? "EMA"  :
                  secPerBarChk >=  7200 ? "EMA"  :
                  secPerBarChk >=  3600 ? "EMA"  :
                  secPerBarChk >=  1800 ? "EMA"  :
                  secPerBarChk >=   900 ? "EMA"  :
                  secPerBarChk >=   300 ? "HMA"  :
                                          "KAMA"

profZMethod     = "Classical"   // Won at every TF in tuning

profZSource     = secPerBarChk >= 86400 ? "Pct Deviation"    :
                  secPerBarChk >= 14400 ? "Pct Deviation"    :
                  secPerBarChk >=  7200 ? "Price − Baseline" :
                  secPerBarChk >=  3600 ? "Log Return"       :
                  secPerBarChk >=  1800 ? "Pct Deviation"    :
                  secPerBarChk >=   900 ? "Price − Baseline" :
                  secPerBarChk >=   300 ? "Price − Baseline" :
                                          "Price − Baseline"

profZSmoother   = secPerBarChk >= 86400 ? "None" :
                  secPerBarChk >= 14400 ? "EMA"  :
                  secPerBarChk >=  7200 ? "None" :
                  secPerBarChk >=  3600 ? "HMA"  :
                  secPerBarChk >=  1800 ? "HMA"  :
                  secPerBarChk >=   900 ? "None" :
                  secPerBarChk >=   300 ? "None" :
                                          "None"

profConviction  = secPerBarChk >= 86400 ? "Medium" :
                  secPerBarChk >= 14400 ? "High"   :
                  secPerBarChk >=  7200 ? "Medium" :
                  secPerBarChk >=  3600 ? "Medium" :
                  secPerBarChk >=  1800 ? "Medium" :
                  secPerBarChk >=   900 ? "Medium" :
                  secPerBarChk >=   300 ? "Medium" :
                                          "Low"

// Effective values — what the rest of the script uses
effTargetDays   = autoTuneByTF ? profTargetDays : targetDays
effBaselineType = autoTuneByTF ? profBaseline   : baselineType
effZMethod      = autoTuneByTF ? profZMethod    : zMethod
effZSource      = autoTuneByTF ? profZSource    : zSource
effZSmoother    = autoTuneByTF ? profZSmoother  : zSmoother
effConviction   = autoTuneByTF ? profConviction : conviction

// TF profile label (for the dashboard)
profLabel       = secPerBarChk >= 86400 ? "1d"  :
                  secPerBarChk >= 14400 ? "4h"  :
                  secPerBarChk >=  7200 ? "2h"  :
                  secPerBarChk >=  3600 ? "1h"  :
                  secPerBarChk >=  1800 ? "30m" :
                  secPerBarChk >=   900 ? "15m" :
                  secPerBarChk >=   300 ? "5m"  :
                                          "1m"


// ═══════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME-ADAPTIVE LOOKBACK
// ═══════════════════════════════════════════════════════════════════════════════
targetBars      = int(effTargetDays * SEC_PER_DAY / math.max(secPerBar, 1.0))
adaptedLen      = math.max(minLookback, math.min(maxLookback, targetBars))
effectiveLen    = autoAdaptTF ? adaptedLen : fixedLength


// ═══════════════════════════════════════════════════════════════════════════════
//  SMOOTHER LIBRARY
// ═══════════════════════════════════════════════════════════════════════════════

// Kaufman Adaptive Moving Average (KAMA)
f_kama(float src_, simple int len_, simple int fast_, simple int slow_) =>
    change_  = math.abs(src_ - src_[len_])
    vola_    = math.sum(math.abs(src_ - src_[1]), len_)
    er_      = vola_ != 0 ? change_ / vola_ : 0.0
    fastSC_  = 2.0 / (fast_ + 1)
    slowSC_  = 2.0 / (slow_ + 1)
    sc_      = math.pow(er_ * (fastSC_ - slowSC_) + slowSC_, 2)
    var float k_ = na
    k_ := na(k_[1]) ? src_ : k_[1] + sc_ * (src_ - k_[1])
    k_

// Unified baseline selector
f_baseline(float src_, simple int len_, simple string kind_) =>
    switch kind_
        "KAMA" => f_kama(src_, len_, 2, 30)
        "HMA"  => ta.hma(src_, len_)
        "ALMA" => ta.alma(src_, len_, 0.85, 6)
        =>        ta.ema(src_, len_)

// Unified Z-line smoother
f_zsmooth(float src_, simple int len_, simple string kind_) =>
    switch kind_
        "ALMA" => ta.alma(src_, len_, 0.85, 6)
        "HMA"  => ta.hma(src_, len_)
        "EMA"  => ta.ema(src_, len_)
        =>        src_


// ═══════════════════════════════════════════════════════════════════════════════
//  Z-SCORE CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════

src      = close
baseline = f_baseline(src, effectiveLen, effBaselineType)

// Choose residual definition based on user's source selection
residual = switch effZSource
    "Price − Baseline" => src - baseline
    "Pct Deviation"    => (src - baseline) / math.max(math.abs(baseline), EPS) * 100.0
    =>                    math.log(src / math.max(baseline, EPS)) * 100.0

// Classical Z
sdClassical = ta.stdev(residual, effectiveLen)
zClassical  = sdClassical != 0 ? residual / sdClassical : 0.0

// Modified Z (Iglewicz & Hoaglin)
medRes      = ta.percentile_linear_interpolation(residual, effectiveLen, 50)
absDev      = math.abs(residual - medRes)
madRes      = ta.percentile_linear_interpolation(absDev, effectiveLen, 50)
zModified   = madRes != 0 ? MAD_K * (residual - medRes) / madRes : 0.0

zRaw        = effZMethod == "Modified (MAD)" ? zModified : zClassical
zSmoothed   = f_zsmooth(zRaw, zSmoothLen, effZSmoother)

// For candle plotting we need OHLC-equivalent z-scores
calcZ(price) =>
    res = switch effZSource
        "Price − Baseline" => price - baseline
        "Pct Deviation"    => (price - baseline) / math.max(math.abs(baseline), EPS) * 100.0
        =>                    math.log(price / math.max(baseline, EPS)) * 100.0
    if effZMethod == "Modified (MAD)"
        madRes != 0 ? MAD_K * (res - medRes) / madRes : 0.0
    else
        sdClassical != 0 ? res / sdClassical : 0.0

zO = calcZ(open)
zH = calcZ(high)
zL = calcZ(low)
zC = zRaw

// Threshold scaling
thrLvl1 = effZMethod == "Modified (MAD)" ? 1.35 : 1.0
thrLvl2 = effZMethod == "Modified (MAD)" ? 2.35 : 2.0
thrLvl3 = effZMethod == "Modified (MAD)" ? 3.50 : 3.0


// ═══════════════════════════════════════════════════════════════════════════════
//  HURST EXPONENT (regime classifier)
// ═══════════════════════════════════════════════════════════════════════════════
diff1   = src - src[1]
diffLag = src - src[hurstLag]
var1    = ta.variance(diff1,   hurstLen)
varN    = ta.variance(diffLag, hurstLen)
hurstRaw = math.log(math.max(varN, EPS) / math.max(var1, EPS)) / (2.0 * math.log(hurstLag))
hurst    = ta.ema(math.max(0.0, math.min(1.0, hurstRaw)), hurstSmooth)

isTrending   = hurst > hurstTrendThr
isReverting  = hurst < hurstRevertThr
isRandom     = not isTrending and not isReverting

regimeName = isTrending ? "TRENDING" : isReverting ? "MEAN-REVERT" : "RANDOM"
regimeColor = isTrending ? bullColor : isReverting ? warnColor : neutralColor


// ═══════════════════════════════════════════════════════════════════════════════
//  HIGHER TIMEFRAME CONFIRMATION
// ═══════════════════════════════════════════════════════════════════════════════
htfTF = switch htfMode
    "Auto (4×)" => timeframe.from_seconds(int(secPerBar * 4))
    "Auto (6×)" => timeframe.from_seconds(int(secPerBar * 6))
    =>             htfManual

htfZ = request.security(syminfo.tickerid, htfTF, zSmoothed,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

htfBullish = htfZ < -thrLvl1 or (htfZ > 0 and htfZ < htfZ[1])
htfBearish = htfZ >  thrLvl1 or (htfZ < 0 and htfZ > htfZ[1])


// ═══════════════════════════════════════════════════════════════════════════════
//  DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
ph_z = ta.pivothigh(zSmoothed, pivotLeft, pivotRight)
pl_z = ta.pivotlow(zSmoothed,  pivotLeft, pivotRight)

var float prevZHigh    = na
var int   prevZHighBar = na
var float lastZHigh    = na
var int   lastZHighBar = na
var float prevZLow     = na
var int   prevZLowBar  = na
var float lastZLow     = na
var int   lastZLowBar  = na

var float prevPHigh    = na
var float lastPHigh    = na
var float prevPLow     = na
var float lastPLow     = na

if not na(ph_z)
    prevZHigh    := lastZHigh
    prevZHighBar := lastZHighBar
    prevPHigh    := lastPHigh
    lastZHigh    := ph_z
    lastZHighBar := bar_index - pivotRight
    lastPHigh    := high[pivotRight]

if not na(pl_z)
    prevZLow    := lastZLow
    prevZLowBar := lastZLowBar
    prevPLow    := lastPLow
    lastZLow    := pl_z
    lastZLowBar := bar_index - pivotRight
    lastPLow    := low[pivotRight]

divBarDistOK_H = not na(prevZHighBar) and not na(lastZHighBar) and (lastZHighBar - prevZHighBar) <= divMaxBars
divBarDistOK_L = not na(prevZLowBar)  and not na(lastZLowBar)  and (lastZLowBar  - prevZLowBar)  <= divMaxBars

zoneOK_bull = not divZoneFilter or lastZLow  < -thrLvl1
zoneOK_bear = not divZoneFilter or lastZHigh >  thrLvl1

regBullDiv  = showRegularDiv and useDivergence and not na(pl_z) and divBarDistOK_L and zoneOK_bull and
     lastPLow  < prevPLow  and lastZLow > prevZLow

regBearDiv  = showRegularDiv and useDivergence and not na(ph_z) and divBarDistOK_H and zoneOK_bear and
     lastPHigh > prevPHigh and lastZHigh < prevZHigh

hidBullDiv  = showHiddenDiv  and useDivergence and not na(pl_z) and divBarDistOK_L and
     lastPLow  > prevPLow  and lastZLow < prevZLow

hidBearDiv  = showHiddenDiv  and useDivergence and not na(ph_z) and divBarDistOK_H and
     lastPHigh < prevPHigh and lastZHigh > prevZHigh

anyBullDiv = regBullDiv or hidBullDiv
anyBearDiv = regBearDiv or hidBearDiv


// ═══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE SCORING ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
totalWeight = w_zReversal + w_divergence + w_slope + w_regime + w_htf + w_volume

zRevBull = ta.crossover(zSmoothed,  -thrLvl2)
zRevBear = ta.crossunder(zSmoothed,  thrLvl2)

slopeBull = baseline > baseline[3]
slopeBear = baseline < baseline[3]

regimeBullOK = isReverting ? (regBullDiv or zRevBull) :
               isTrending  ? (hidBullDiv or (slopeBull and zSmoothed < 0)) :
               false
regimeBearOK = isReverting ? (regBearDiv or zRevBear) :
               isTrending  ? (hidBearDiv or (slopeBear and zSmoothed > 0)) :
               false

hasVol      = nz(volume, 0) > 0
volMean     = ta.sma(volume, effectiveLen)
volSD       = ta.stdev(volume, effectiveLen)
volZ        = (volSD != 0 and hasVol) ? (volume - volMean) / volSD : 0.0
volOK       = hasVol and volZ > 1.0

bullScore = (zRevBull                       ? w_zReversal  : 0) +
  (anyBullDiv                     ? w_divergence : 0) +
  (slopeBull                      ? w_slope      : 0) +
  (useHurst  and regimeBullOK     ? w_regime     : 0) +
  (useHTF    and htfBullish       ? w_htf        : 0) +
  (useVolume and volOK            ? w_volume     : 0)

bearScore = (zRevBear                       ? w_zReversal  : 0) +
  (anyBearDiv                     ? w_divergence : 0) +
  (slopeBear                      ? w_slope      : 0) +
  (useHurst  and regimeBearOK     ? w_regime     : 0) +
  (useHTF    and htfBearish       ? w_htf        : 0) +
  (useVolume and volOK            ? w_volume     : 0)

bullPct = totalWeight > 0 ? bullScore / totalWeight * 100.0 : 0.0
bearPct = totalWeight > 0 ? bearScore / totalWeight * 100.0 : 0.0

convThreshold = switch effConviction
    "Low"    => 50.0
    "Medium" => 65.0
    =>          80.0

strongBuy  = showSignals and bullPct >= convThreshold and bullPct > bearPct
strongSell = showSignals and bearPct >= convThreshold and bearPct > bullPct

weakBuy    = showSignals and bullPct >= 35.0 and bullPct > bearPct and not strongBuy
weakSell   = showSignals and bearPct >= 35.0 and bearPct > bullPct and not strongSell


// ═══════════════════════════════════════════════════════════════════════════════
//  PLOT — Z-Score area / line / candles
// ═══════════════════════════════════════════════════════════════════════════════
zFillColor = zSmoothed >= 0 ? color.new(bullColor, 55) : color.new(bearColor, 55)
zEdgeColor = zSmoothed >= 0 ? color.new(bullColor, 0)  : color.new(bearColor, 0)

plot(plotStyle == "Area" ? zSmoothed : na, "Z-Score Area",
     color=zFillColor, style=plot.style_area, display=display.pane)

plot(plotStyle == "Area" or plotStyle == "Line" ? zSmoothed : na, "Z-Score",
     color=zEdgeColor, linewidth=plotStyle == "Line" ? 2 : 1)

candleClr = zO > zC ? color.new(bearColor, 0) : color.new(bullColor, 0)
plotcandle(plotStyle == "Candles" ? zO : na,
           plotStyle == "Candles" ? zH : na,
           plotStyle == "Candles" ? zL : na,
           plotStyle == "Candles" ? zC : na,
     title="Z Candles", color=candleClr, wickcolor=candleClr, bordercolor=candleClr,
     display=plotStyle == "Candles" ? display.all : display.none)


// ═══════════════════════════════════════════════════════════════════════════════
//  PLOT — Reference line hierarchy & optional zones
// ═══════════════════════════════════════════════════════════════════════════════
zeroLineP = plot(0,         "Zero",  color=color.new(color.black, 100), display=display.pane, editable=false)
p1 = plot( thrLvl1, "+1σ", color=color.new(color.black, 100), display=display.pane, editable=false)
n1 = plot(-thrLvl1, "-1σ", color=color.new(color.black, 100), display=display.pane, editable=false)
p2 = plot( thrLvl2, "+2σ", color=color.new(color.black, 100), display=display.pane, editable=false)
n2 = plot(-thrLvl2, "-2σ", color=color.new(color.black, 100), display=display.pane, editable=false)
p3 = plot( thrLvl3, "+3σ", color=color.new(color.black, 100), display=display.pane, editable=false)
n3 = plot(-thrLvl3, "-3σ", color=color.new(color.black, 100), display=display.pane, editable=false)

zoneInner = showZones ? color.new(neutralColor, 92) : color.new(color.black, 100)
zoneMid   = showZones ? color.new(neutralColor, 87) : color.new(color.black, 100)
zoneOuter = showZones ? color.new(critColor,    86) : color.new(color.black, 100)
fill(zeroLineP, p1, color=zoneInner)
fill(zeroLineP, n1, color=zoneInner)
fill(p1, p2,        color=zoneMid)
fill(n1, n2,        color=zoneMid)
fill(p2, p3,        color=zoneOuter)
fill(n2, n3,        color=zoneOuter)

hline(0,         "Zero",   color=color.new(neutralColor, 50), linestyle=hline.style_solid)
hline( thrLvl1,  "+1σ",    color=color.new(neutralColor, 85), linestyle=hline.style_dotted)
hline(-thrLvl1,  "-1σ",    color=color.new(neutralColor, 85), linestyle=hline.style_dotted)
hline( thrLvl2,  "+2σ",    color=color.new(neutralColor, 55), linestyle=hline.style_dotted)
hline(-thrLvl2,  "-2σ",    color=color.new(neutralColor, 55), linestyle=hline.style_dotted)
hline( thrLvl3,  "+3σ",    color=color.new(critColor,    40), linestyle=hline.style_dashed)
hline(-thrLvl3,  "-3σ",    color=color.new(critColor,    40), linestyle=hline.style_dashed)


// ═══════════════════════════════════════════════════════════════════════════════
//  PLOT — Divergence markers
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(regBullDiv, "Regular Bull Div", shape.triangleup,   location.bottom, bullColor,  size=size.tiny)
plotshape(regBearDiv, "Regular Bear Div", shape.triangledown, location.top,    bearColor,  size=size.tiny)
plotshape(hidBullDiv, "Hidden Bull Div",  shape.diamond,      location.bottom, bullColor,  size=size.tiny)
plotshape(hidBearDiv, "Hidden Bear Div",  shape.diamond,      location.top,    bearColor,  size=size.tiny)


// ═══════════════════════════════════════════════════════════════════════════════
//  PLOT — Strong Buy / Sell signal labels
// ═══════════════════════════════════════════════════════════════════════════════
if strongBuy
    label.new(bar_index, -thrLvl3 * 1.05,
         text=" ▲ STRONG BUY  " + str.tostring(bullPct, "#") + " ",
         color=bullColor, textcolor=color.black, style=label.style_label_up,
         size=size.small, textalign=text.align_center)

if strongSell
    label.new(bar_index,  thrLvl3 * 1.05,
         text=" ▼ STRONG SELL  " + str.tostring(bearPct, "#") + " ",
         color=bearColor, textcolor=color.black, style=label.style_label_down,
         size=size.small, textalign=text.align_center)

plotshape(weakBuy,  "Buy Arrow",  shape.arrowup,   location.bottom, color.new(bullColor, 50), size=size.tiny)
plotshape(weakSell, "Sell Arrow", shape.arrowdown, location.top,    color.new(bearColor, 50), size=size.tiny)


// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

f_dashPos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Middle Right"  => position.middle_right
        =>                 position.top_right

f_dashSize(s) =>
    switch s
        "Small"  => size.small
        "Large"  => size.large
        =>          size.normal

f_minibar(float pct, simple int segs) =>
    filled = int(math.round(math.max(0.0, math.min(100.0, pct)) / 100.0 * segs))
    bar = ""
    for i = 0 to segs - 1
        bar := bar + (i < filled ? "█" : "░")
    bar

var table dash = na

if showDashboard and barstate.islast
    if not na(dash)
        table.delete(dash)
    // 11 rows now (header + Auto-Tune row + 9 existing)
    dash := table.new(f_dashPos(dashPos), 2, 11,
         bgcolor=chromeBg,
         border_width=1,
         border_color=chromeDivide,
         frame_width=0)

    txtSize = f_dashSize(dashSize)
    monoF   = font.family_monospace

    // Header
    headerBg = color.new(chromeBorder, 30)
    regimeDot = isTrending ? bullColor : isReverting ? critColor : neutralColor
    table.cell(dash, 0, 0, "Z-PRO",
         bgcolor=headerBg, text_color=textPrimary, text_size=txtSize,
         text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 0, "● " + regimeName,
         bgcolor=headerBg, text_color=regimeDot, text_size=txtSize,
         text_halign=text.align_right, text_font_family=monoF)

    // Row 1: Auto-Tune profile
    autoTuneTxt = autoTuneByTF ? profLabel + " profile" : "manual"
    autoTuneClr = autoTuneByTF ? bullColor : textMuted
    table.cell(dash, 0, 1, "Auto-Tune",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 1, autoTuneTxt,
         text_color=autoTuneClr, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 2: Chart TF
    table.cell(dash, 0, 2, "Chart TF",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 2, timeframe.period,
         text_color=textPrimary, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 3: Lookback
    lookbackTxt = str.tostring(effectiveLen) + (autoAdaptTF ? " auto" : " fixed")
    table.cell(dash, 0, 3, "Lookback",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 3, lookbackTxt,
         text_color=textPrimary, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 4: Z-score
    zCellColor = math.abs(zSmoothed) >= thrLvl2 ? (zSmoothed > 0 ? bullColor : bearColor) :
                 math.abs(zSmoothed) >= thrLvl1 ? textPrimary :
                 textMuted
    table.cell(dash, 0, 4, "Z-Score",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 4, str.tostring(zSmoothed, "0.00") + "σ",
         text_color=zCellColor, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 5: Hurst
    table.cell(dash, 0, 5, "Hurst",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 5, str.tostring(hurst, "0.00"),
         text_color=textPrimary, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 6: HTF
    htfArrow = htfBullish ? " ↑" : htfBearish ? " ↓" : " ·"
    htfTxt   = useHTF ? str.tostring(htfZ, "0.00") + htfArrow : "off"
    htfClr   = not useHTF ? textMuted : htfBullish ? bullColor : htfBearish ? bearColor : textPrimary
    table.cell(dash, 0, 6, "HTF " + htfTF,
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 6, htfTxt,
         text_color=htfClr, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 7: Bull score
    bullBar = f_minibar(bullPct, 8) + " " + str.tostring(bullPct, "#")
    bullClr = bullPct >= convThreshold ? bullColor : textPrimary
    table.cell(dash, 0, 7, "Bull",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 7, bullBar,
         text_color=bullClr, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 8: Bear score
    bearBar = f_minibar(bearPct, 8) + " " + str.tostring(bearPct, "#")
    bearClr = bearPct >= convThreshold ? bearColor : textPrimary
    table.cell(dash, 0, 8, "Bear",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 8, bearBar,
         text_color=bearClr, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 9: Conviction tier
    table.cell(dash, 0, 9, "Conviction",
         text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 9, effConviction + " ≥" + str.tostring(convThreshold, "#"),
         text_color=textPrimary, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)

    // Row 10: Signal
    signalTxt = strongBuy ? "▲ STRONG BUY" : strongSell ? "▼ STRONG SELL" : weakBuy ? "▲ Buy" : weakSell ? "▼ Sell" : "—"
    signalClr = strongBuy or weakBuy ? bullColor : strongSell or weakSell ? bearColor : textMuted
    signalBg  = strongBuy ? color.new(bullColor, 85) : strongSell ? color.new(bearColor, 85) : color.new(chromeBorder, 50)
    table.cell(dash, 0, 10, "Signal",
         bgcolor=signalBg, text_color=textMuted, text_size=txtSize, text_halign=text.align_left, text_font_family=monoF)
    table.cell(dash, 1, 10, signalTxt,
         bgcolor=signalBg, text_color=signalClr, text_size=txtSize, text_halign=text.align_right, text_font_family=monoF)


// ═══════════════════════════════════════════════════════════════════════════════
//  PROBABILITY TABLE
// ═══════════════════════════════════════════════════════════════════════════════
var table zTbl = na

if showZTable and barstate.islast
    if not na(zTbl)
        table.delete(zTbl)
    zTbl := table.new(position.bottom_right, 3, 8,
         bgcolor=chromeBg,
         border_width=1, border_color=chromeDivide,
         frame_width=0)

    zMono = font.family_monospace
    zHeaderBg = color.new(chromeBorder, 30)

    table.cell(zTbl, 0, 0, "Z",     bgcolor=zHeaderBg, text_color=textPrimary, text_size=size.small, text_font_family=zMono)
    table.cell(zTbl, 1, 0, "P(≤z)", bgcolor=zHeaderBg, text_color=textPrimary, text_size=size.small, text_font_family=zMono)
    table.cell(zTbl, 2, 0, "Zone",  bgcolor=zHeaderBg, text_color=textPrimary, text_size=size.small, text_font_family=zMono)

    zVals = array.from(-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0)
    pVals = array.from("0.13", "2.28", "15.87", "50.00", "84.13", "97.72", "99.87")

    for i = 0 to 6
        z = array.get(zVals, i)
        p = array.get(pVals, i)
        zc = math.abs(z) >= 2.0 ? (z > 0 ? bullColor : bearColor) : math.abs(z) >= 1.0 ? critColor : textMuted
        table.cell(zTbl, 0, i + 1, str.tostring(z, "0.0"),
             text_color=textPrimary, text_size=size.small, text_font_family=zMono, text_halign=text.align_right)
        table.cell(zTbl, 1, i + 1, p,
             text_color=textMuted,   text_size=size.small, text_font_family=zMono, text_halign=text.align_right)
        table.cell(zTbl, 2, i + 1, "",
             bgcolor=color.new(zc, 60))


// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(strongBuy,  title="Strong Buy",
     message="Z-Pro Strong BUY on {{ticker}} ({{interval}}) — bull score above conviction threshold")
alertcondition(strongSell, title="Strong Sell",
     message="Z-Pro Strong SELL on {{ticker}} ({{interval}}) — bear score above conviction threshold")
alertcondition(weakBuy,    title="Buy Setup",
     message="Z-Pro buy setup forming on {{ticker}} ({{interval}})")
alertcondition(weakSell,   title="Sell Setup",
     message="Z-Pro sell setup forming on {{ticker}} ({{interval}})")
alertcondition(regBullDiv, title="Regular Bullish Divergence",
     message="Z-Pro regular bullish divergence on {{ticker}}")
alertcondition(regBearDiv, title="Regular Bearish Divergence",
     message="Z-Pro regular bearish divergence on {{ticker}}")
alertcondition(hidBullDiv, title="Hidden Bullish Divergence",
     message="Z-Pro hidden bullish divergence on {{ticker}}")
alertcondition(hidBearDiv, title="Hidden Bearish Divergence",
     message="Z-Pro hidden bearish divergence on {{ticker}}")
alertcondition(ta.crossover(zSmoothed,  thrLvl2),  title="Z Crosses Above +2σ",
     message="Z-Pro: {{ticker}} crossed above +2σ — overbought zone")
alertcondition(ta.crossunder(zSmoothed, -thrLvl2), title="Z Crosses Below -2σ",
     message="Z-Pro: {{ticker}} crossed below -2σ — oversold zone")
alertcondition(isTrending and not isTrending[1],   title="Regime → Trending",
     message="Z-Pro regime shifted to TRENDING on {{ticker}}")
alertcondition(isReverting and not isReverting[1], title="Regime → Mean-Reverting",
     message="Z-Pro regime shifted to MEAN-REVERTING on {{ticker}}")
````
