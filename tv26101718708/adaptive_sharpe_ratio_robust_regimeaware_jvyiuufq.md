# Adaptive Sharpe Ratio (Robust & Regime-Aware)

- url: https://www.tradingview.com/script/JVyIUUfQ-Adaptive-Sharpe-Ratio-Robust-Regime-Aware/
- type: indicator
- pine_id: PUB;4013a0f45bb2431eb2b668701df74ba1
- version: 1.0

## Description

Adaptive Sharpe Ratio (Robust & Regime-Aware) — ASR+


ASR+ (Adaptive Sharpe Ratio) on a daily chart, highlighting regime shifts and dynamically adjusted risk-aware performance.

WHAT IS ASR+

ASR+ (Adaptive Sharpe Ratio) is an enhanced version of the traditional Sharpe Ratio designed to remain statistically reliable in real market conditions.

It improves on the standard model by correcting for autocorrelation, fat tails, and regime-dependent volatility—factors that routinely distort conventional Sharpe readings.

The result is a more stable, realistic measure of risk-adjusted performance that adapts across timeframes, asset classes, and market environments.

WHY THIS MATTERS

The standard Sharpe Ratio assumes:

Stable volatility
Independent returns
Normally distributed returns

Real markets violate all of these assumptions.

Result: Sharpe can become inflated, unstable, and misleading—often underestimating risk, especially on lower timeframes.

ASR+ is designed to overcome these shortcomings.

WHAT “ROBUST” MEANS

ASR+ is built to resist common distortions:

Outliers & fat tails → adjusted
Skewed returns → penalized
Autocorrelation → corrected (HAC / Newey–West)
Small samples → estimation bias reduced

Result: more stable and realistic Sharpe values.

WHAT “REGIME-AWARE” MEANS

Markets change — volatility and behavior shift.

ASR+ adapts dynamically:

High volatility → stronger risk penalty
Calm markets → normalized evaluation
Regime shifts → reflected in real time

Result: avoids false confidence during risky conditions.

─────────────────────────────────────────

WHAT MAKES ASR+ DIFFERENT

─────────────────────────────────────────

🔹 HAC Autocorrelation Correction (Newey-West)
Uses a 4-lag Bartlett kernel to correct for serial correlation in returns. When returns are trending or mean-reverting, standard volatility estimates are biased. ASR+ adjusts variance to prevent Sharpe inflation during momentum regimes.

🔹 Cornish-Fisher Tail Adjustment
Incorporates skewness and excess kurtosis into the risk estimate. Markets with fat tails or negative skew carry more downside risk than standard deviation alone captures. This adjustment penalizes asymmetric or heavy-tailed return distributions at the 95% confidence level.

🔹 Volatility Regime Penalty
Detects when current volatility is elevated relative to its historical average and applies a dynamic penalty. ASR+ becomes more conservative exactly when standard Sharpe is most likely to mislead.

🔹 Small-Sample Uncertainty Correction
Applies a bias correction to the mean return estimate, accounting for statistical uncertainty from limited observations. Shorter lookbacks carry more estimation error, which ASR+ reflects.

🔹 Adaptive Risk Adjustment
All adjustments — tail risk, volatility regime, autocorrelation, and estimation uncertainty — are combined through an interaction-aware framework. This prevents double-counting while allowing interacting risk factors to generate appropriately compounded penalties. The total adjustment is capped to avoid over-penalization.

🔹 Multi-Asset, Multi-Timeframe Scaling
Automatically detects asset type (crypto, equities, forex, futures) and timeframe (seconds through monthly) and applies appropriate annualization.

Crypto → 365-day, 24-hour markets
Equities → 252-day, 6.5-hour sessions

No manual configuration required.

🔹 Extreme Value Moderation
During periods of high volatility or reduced estimation reliability, ASR+ moderates extreme Sharpe values in both directions. Positive readings may be reduced, while negative readings may move closer to zero, reflecting lower statistical confidence rather than a change in underlying performance.

🔹 Logarithmic Returns
ASR+ uses logarithmic (log) returns instead of arithmetic returns. Log returns are time-additive and more statistically consistent across timeframes, improving the stability and comparability of risk-adjusted performance, particularly over longer horizons and in the presence of compounding.

ADAPTIVE VS STANDARD SHARPE

Toggle between:

Standard Sharpe → baseline calculation (thinner line)
ASR+ → adjusted, real-world version (thicker line)

Use this to:

Detect inflated Sharpe values
Reveal hidden risk
Validate strategy robustness

─────────────────────────────────────────

REGIME CLASSIFICATION

─────────────────────────────────────────

Light theme view for clarity and accessibility. The same regime classification logic is applied across themes.

ASR+ colors both the plotted line and background for instant interpretation:

🔴 Red → Below 0 — Negative risk-adjusted return
⚫ Gray → 0 to 1 — Subpar performance
🟢 Green → 1 to 2 — Good performance
💚 Lime → Above 2 — Exceptional performance

─────────────────────────────────────────

KEY INPUTS & SETTINGS

─────────────────────────────────────────

→ Lookback Period
Minimum: 50 bars (Daily & Intraday), 36 (Weekly), 24 (Monthly)
Recommended: 63 (Daily), 100 (4H), 252 (1H), 500 (30M)

For high-volatility assets (e.g., growth stocks, crypto), longer lookbacks are recommended to reduce sensitivity to short-term trends
Short lookbacks during strong trending conditions can produce elevated readings that reflect momentum rather than sustainable risk-adjusted performance

→ Risk-Free Rate
Annualized (default 4.5%), adjustable to reflect prevailing rates

→ Show Adaptive vs Standard Sharpe
Plot both to visualize adjustment magnitude

→ EMA Smoother
Optional smoothing to reduce noise

→ Background Regime Colors
Fully customizable

─────────────────────────────────────────

WHO THIS IS FOR

─────────────────────────────────────────

→ Quantitative traders evaluating strategies
→ Multi-asset traders needing consistent metrics
→ Risk-conscious traders focused on efficiency, not just returns
→ Systematic traders monitoring regime shifts in real time

IMPORTANT

ASR+ is not a buy/sell signal.

It measures the quality of returns to support:

Strategy evaluation
Risk control
Position sizing

All calculations are based on confirmed historical data and do not rely on future values.

─────────────────────────────────────────
Built with statistical rigor for traders who demand more accurate evaluation tools.
─────────────────────────────────────────

## Source Code

````pine
//@version=6
// © TrendAdvantage
// ═══════════════════════════════════════════════════
// Adaptive Sharpe Ratio (Robust & Regime-Aware) — ASR+
// ═══════════════════════════════════════════════════
// Description:
// A robust, regime-aware Sharpe Ratio designed for realistic risk-adjusted performance measurement.
//
// Methodology:
//   • HAC Variance Estimation (Newey-West)
//   • Tail Risk Adjustment (Cornish-Fisher Expansion)
//   • Dynamic Volatility Regime Adaptation
//   • Small-Sample Bias Correction
//   • Adaptive Risk Penalty Framework (interaction-aware)
//   • Multi-Asset Annualization (Crypto / Equities / Forex)
// ═══════════════════════════════════════════════════
// License: Mozilla Public License 2.0 (MPL-2.0)
// https://mozilla.org/MPL/2.0/
// This source code is subject to the terms of the MPL 2.0.
// Any derivative work must retain this copyright notice.
// ═══════════════════════════════════════════════════
// TradingView: tradingview.com/u/TrendAdvantage
// ═══════════════════════════════════════════════════
indicator("Adaptive Sharpe Ratio (Robust & Regime-Aware)", shorttitle="ASR+", overlay=false, precision=3)

// ==========================================
// ===== INPUTS & DYNAMIC LOOKBACK      =====
// ==========================================
N_input  = input.int(100, "Lookback Period", minval=24, tooltip="Minimums enforced: Monthly 24, Weekly 36, Daily/Intraday 50. Recommended: Daily 63, 4h 100, 1h 252, 30m 500.")
annualRf = input.float(4.5, "Risk-Free %") / 100.0

// Statistical enforcement logic
int effectiveMinN = timeframe.ismonthly ? 24 : timeframe.isweekly ? 36 : 50
int N = math.max(N_input, effectiveMinN)

showASR   = input.bool(true, "Show Adaptive Sharpe", group="Visibility")
showStd   = input.bool(false, "Show Standard Sharpe", group="Visibility")

showEMA   = input.bool(true, "Show EMA Smoothers", group="Visibility")
emaLen    = input.int(5, "EMA Length", minval=1, group="Visibility")
showBG    = input.bool(true, "Show Background Risk Regimes", group="Visibility")

// Background Color Customization
negCol    = input.color(color.new(color.red, 90), "Negative Regime (<0)", group="Background Colors")
neutCol   = input.color(color.new(color.gray, 90), "Neutral Regime (0-1)", group="Background Colors")
goodCol   = input.color(color.new(color.green, 90), "Good Regime (1-2)", group="Background Colors")
excelCol  = input.color(color.new(color.lime, 90), "Excellent Regime (>2)", group="Background Colors")

// ==========================================
// ===== HARD-CODED CALIBRATION         =====
// ==========================================
const float TAIL_SENSE = 0.7  
const float VOL_SENSE  = 0.5 
const float UNC_SENSE  = 0.3 

// ==========================================
// ===== TIME SCALING (MULTI-ASSET)     =====
// ==========================================
yearlyDays = (syminfo.type == "crypto" or syminfo.type == "economy") ? 365.0 : 252.0
dailyHours = (syminfo.type == "stock" or syminfo.type == "fund") ? 6.5 : 24.0

float barsPerYear = na

if timeframe.isseconds
    barsPerYear := (yearlyDays * dailyHours * 3600.0) / timeframe.multiplier
else if timeframe.isminutes
    barsPerYear := (yearlyDays * dailyHours * 60.0) / timeframe.multiplier
else if timeframe.isdaily
    barsPerYear := yearlyDays
else if timeframe.isweekly
    barsPerYear := 52.0
else if timeframe.ismonthly
    barsPerYear := 12.0
else
    barsPerYear := yearlyDays

annFactor = math.sqrt(barsPerYear)

// ==========================================
// ===== RETURNS & BASE STATS           =====
// ==========================================
ret    = math.log(close / close[1])
rf_bar = math.log(1.0 + annualRf) / barsPerYear
excess = ret - rf_bar

mean = ta.sma(excess, N)
var0 = ta.variance(excess, N)
std0 = math.sqrt(math.max(var0, 1e-10))

// ==========================================
// ===== HAC (4-LAG BARTLETT KERNEL)    =====
// ==========================================
rho1 = ta.correlation(excess, excess[1], N)
rho2 = ta.correlation(excess, excess[2], N)
rho3 = ta.correlation(excess, excess[3], N)
rho4 = ta.correlation(excess, excess[4], N)

nwSum = 0.8*rho1 + 0.6*rho2 + 0.4*rho3 + 0.2*rho4
hacFactor = math.max(1.0 + 2.0 * nwSum, 1.0)
hacVar = var0 * hacFactor

// ==========================================
// ===== CORNISH-FISHER ADJUSTMENT      =====
// ==========================================
skew = ta.sma(math.pow(excess - mean, 3), N) / math.pow(std0, 3)
kurt = ta.sma(math.pow(excess - mean, 4), N) / math.pow(std0, 4) - 3.0

s_c = math.max(math.min(skew, 2.0), -2.0)
k_c = math.max(math.min(kurt, 5.0), -1.0)

z = 1.645 
cfAdj = 1.0 + (s_c/6.0)*(z*z - 1.0) + (k_c/24.0)*(z*z*z - 3.0*z)
cfAdj := math.max(math.min(cfAdj, 1.5), 0.8)

// ==========================================
// ===== ADAPTIVE RISK ADJUSTMENTS      =====
// ==========================================
tailPenalty = 1.0 + TAIL_SENSE * math.max(cfAdj - 1.0, 0.0)
avgStd      = ta.sma(std0, N)
volRatio    = std0 / math.max(avgStd, 1e-10)
volPenalty  = 1.0 + VOL_SENSE * math.max(volRatio - 1.0, 0.0)
uncPenalty  = 1.0 + UNC_SENSE * math.sqrt(1.0 / N)

interaction = 0.15 * (tailPenalty - 1.0) * (volPenalty - 1.0)
adjFactor   = math.min(1.0 + (tailPenalty - 1.0) + (volPenalty - 1.0) + (uncPenalty - 1.0) + interaction, 2.5)

// ==========================================
// ===== FINAL CALCULATION              =====
// ==========================================
adjVar   = math.max(hacVar * adjFactor, var0 * 0.95)
adjStd   = math.sqrt(adjVar)
mean_adj = mean / (1.0 + 1.0 / math.sqrt(N))

adaptiveSharpe = (mean_adj / adjStd) * annFactor
standardSharpe = (mean / std0) * annFactor

// ==========================================
// ===== RUNTIME WARNING LABEL          =====
// ==========================================
var label warningLabel = na

// Manual line breaks (\n) to reduce width
string warningText = "⚠️ ASR+ Warning\n" + 
     "Lookback increased to " + str.tostring(effectiveMinN) + " for stability.\n" +
     "------------------------------------------\n" +
     "The input menu still shows " + str.tostring(N_input) + ",\n" +
     "but " + str.tostring(effectiveMinN) + " is being applied internally."

if barstate.islast
    if N_input < effectiveMinN
        if na(warningLabel)
            warningLabel := label.new(bar_index, adaptiveSharpe, warningText, 
                 color=color.new(color.orange, 10), 
                 textcolor=color.white, 
                 style=label.style_label_up,
                 yloc=yloc.price,
                 size=size.small) // Added 'size.small' to further reduce footprint
        else
            label.set_xy(warningLabel, bar_index, adaptiveSharpe)
            label.set_text(warningLabel, warningText)
    else
        if not na(warningLabel)
            label.delete(warningLabel)
            warningLabel := na

// Smoothing
emaASR = ta.ema(adaptiveSharpe, emaLen)
emaSTD = ta.ema(standardSharpe, emaLen)

// ==========================================
// ===== VISUALS & PLOTTING             =====
// ==========================================
f_color(x) =>
    x < 0 ? color.red : x < 1 ? color.gray : x < 2 ? color.green : color.lime

asrColor = f_color(adaptiveSharpe)
stdColor = color.new(f_color(standardSharpe), 40)

// Background Logic
var color dynamicBG = na
if showBG
    dynamicBG := adaptiveSharpe < 0 ? negCol   : 
                 adaptiveSharpe < 1 ? neutCol  : 
                 adaptiveSharpe < 2 ? goodCol  : 
                 excelCol

bgcolor(showBG ? dynamicBG : na)

// Plots
plot(showASR ? adaptiveSharpe : na, "Adaptive Sharpe", color=asrColor, linewidth=2)
plot(showStd ? standardSharpe : na, "Standard Sharpe", color=stdColor, linewidth=1)

plot(showEMA and showASR ? emaASR : na, "ASR EMA", color=color.orange, linewidth=2)
plot(showEMA and showStd ? emaSTD : na, "STD EMA", color=color.blue, linewidth=1)

hline(0, "Zero Line", color=color.gray)
hline(1, "Target Threshold", color=color.new(color.green, 50), linestyle=hline.style_dotted)
````
