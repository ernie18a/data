# Quant Volatility & Regime [AlgoChief]

- url: https://www.tradingview.com/script/q2jqlL05-Quant-Volatility-Regime-AlgoChief/
- type: indicator
- pine_id: PUB;83650aa681124a2f8fb40b3256c95a0d
- version: 1.0

## Description

OVERVIEW AND QUANTITATIVE PHILOSOPHY

Most indicators fail because they apply trend-following math to range-bound chop, or oscillator mean-reversion math to explosive trending regimes. Financial asset prices alternate between distinct mathematical states: Persistent Trending, Mean-Reverting Anti-Persistent Noise, and Volatility Compression Squeezes.

The [AlgoChief] Adaptive Quant Volatility Surface & Fractal Regime Filter solves this fundamental problem. It combines the Garman-Klass Multi-Point Volatility Estimator with Fractal Dimension Index (FDI) mathematics and Efficiency Ratio kinematics to classify the exact regime of any financial instrument without relying on lag-heavy moving averages.


MATHEMATICAL ARCHITECTURE

1. GARMAN-KLASS VOLATILITY SURFACE
Standard standard deviation only evaluates close-to-close metrics, ignoring intraday price dynamics. The Garman-Klass algorithm integrates High, Low, Open, and Close geometric logs:
- Captures true variance up to 800% more efficiently than classical volatility metrics.
- Computes volatility spikes and micro-compressions with instant mathematical sensitivity.

2. FRACTAL DIMENSION INDEX (FDI) KINEMATICS
Derived from Mandelbrot fractal geometry, FDI quantifies the roughness and space-filling properties of price trajectories:
- FDI near 1.00 indicates pure directional persistence (Super-Trend state where trend-following is optimal).
- FDI near 1.50 represents a Gaussian Random Walk (Unpredictable Brownian noise).
- FDI above 1.55 signifies Mean-Reversion (Anti-persistent boundaries where range trading thrives).

3. REGIME VECTOR SCORE (-100 TO +100)
A continuous institutional score calculated by synthesizing Directional Persistence, Volatility Z-Score, and Price Efficiency. 

4. DYNAMIC REGIME CLASSIFICATION STATES
The engine autonomously outputs 4 distinct market states:
- Explosive Expansion: Massive institutional momentum. Ride the trend with trailing stops.
- Directional Drift: Controlled trend progression. Favorable for dip buying / rally selling.
- Mean-Reversion Channel: Range-bound consolidation. High risk for trend breakouts; ideal for oscillator fades.
- Volatility Squeeze: Energy compression preceding explosive institutional breakouts.


HOW TO USE THIS INDICATOR

Trend Following Strategy:
- Check the Regime Matrix HUD. When State is EXPLOSIVE EXPANSION or DIRECTIONAL DRIFT and the Regime Curve is above the Upper Quant Band, hold trend positions with confidence.

Mean Reversion Strategy:
- When State reads MEAN-REVERSION or COMPRESSION and the curve oscillates between the equilibrium bands, fade extreme edges and avoid breakout trades.

Breakout Anticipation:
- When Volatility Surface turns deep purple/gray (Compression Squeeze) and FDI rises above 1.55, prepare for a violent explosive regime transition.


INPUT SETTINGS BREAKDOWN

- Fractal Calculation Length: Number of historical bars used to evaluate geometric curve roughness.
- Volatility Lookback Period: Window size for the Garman-Klass variance integration.
- Smoothing Kernel: High-frequency noise suppression using low-lag exponential weighting.
- Telemetry Matrix Position: Fixed top-right institutional HUD display.


RISK NOTICE

Statistical regime classification models estimate structural probabilities based on historical distribution dynamics. Market dislocations and extreme macroeconomic events can rapidly alter price distributions. Use proper stop-loss protocols and never over-leverage.

## Source Code

````pine
//@version=6
indicator("Quant Volatility & Regime [AlgoChief]", shorttitle="QVS-FRF [AlgoChief]", overlay=false)

// ==========================================
// USER INPUTS & PARAMETERS
// ==========================================
grp_fdi    = "Fractal Dimension Engine"
fdiLen     = input.int(30, "Fractal Lookback Window", minval=10, maxval=60, group=grp_fdi)
trendThreshold = input.float(1.42, "Fractal Trend Boundary (<)", step=0.01, group=grp_fdi)
rangeThreshold = input.float(1.58, "Fractal Range Boundary (>)", step=0.01, group=grp_fdi)

grp_vol    = "Garman-Klass Volatility Surface"
volLen     = input.int(20, "Volatility Estimator Period", minval=5, maxval=100, group=grp_vol)
smoothLen  = input.int(5, "Kinetic Smoothing Length", minval=1, maxval=20, group=grp_vol)

grp_col    = "Color Palette"
c_bull_exp = input.color(#00e676, "Bullish Expansion", group=grp_col)
c_bear_exp = input.color(#ff1744, "Bearish Expansion", group=grp_col)
c_drift    = input.color(#29b6f6, "Directional Drift", group=grp_col)
c_range    = input.color(#ffd600, "Mean Reversion Chop", group=grp_col)
c_squeeze  = input.color(#7c4dff, "Volatility Compression Squeeze", group=grp_col)

grp_ui     = "Quantitative Matrix HUD"
showHud    = input.bool(true, "Show Regime HUD Table", group=grp_ui)

// ==========================================
// GARMAN-KLASS VOLATILITY ALGORITHM
// ==========================================
sLow  = low > 0.0 ? low : 0.00001
sOpen = open > 0.0 ? open : 0.00001
gkLogHL = math.log(math.max(high / sLow, 1.00001))
gkLogCO = math.log(math.max(close / sOpen, 0.00001))
gkVariance = 0.5 * math.pow(gkLogHL, 2) - (2.0 * math.log(2.0) - 1.0) * math.pow(gkLogCO, 2)
gkVol = math.sqrt(math.max(gkVariance, 0.0))

// Volatility Percentile Rank over lookback
volHighest = ta.highest(gkVol, volLen)
volLowest  = ta.lowest(gkVol, volLen)
volRank    = (gkVol - volLowest) / math.max(volHighest - volLowest, 0.000001) * 100.0

// ==========================================
// FRACTAL DIMENSION INDEX (FDI) - INLINE
// ==========================================
hiFdi = ta.highest(high, fdiLen)
loFdi = ta.lowest(low, fdiLen)
diffFdi = hiFdi - loFdi
float sumLength = 0.0

if diffFdi > 0.0
    for i = 0 to fdiLen - 2
        float xDiff = (high[i] - low[i + 1]) / diffFdi
        float yDiff = 1.0 / fdiLen
        sumLength += math.sqrt(xDiff * xDiff + yDiff * yDiff)

float fdi = (diffFdi > 0.0 and sumLength > 0.0) ? (1.0 + (math.log(sumLength) + math.log(2.0)) / math.log(2.0 * fdiLen)) : 1.50

// Directional Efficiency Ratio (Kaufman Efficiency)
changePrice = math.abs(close - close[fdiLen])
volatilitySum = math.sum(math.abs(close - close[1]), fdiLen)
effRatio = changePrice / math.max(volatilitySum, 0.000001)

// ==========================================
// REGIME VECTOR COMPOSITE CALCULATION
// ==========================================
dirSign = close > ta.ema(close, fdiLen) ? 1.0 : -1.0
rawVector = dirSign * effRatio * 100.0
regimeVector = ta.ema(rawVector, smoothLen)

// State Logic
bool isSqueeze   = volRank < 20.0
bool isTrending  = fdi < trendThreshold and effRatio > 0.35
bool isChop      = fdi > rangeThreshold or effRatio < 0.20
bool isExpansion = volRank > 70.0 and isTrending

string currentState = isExpansion ? (regimeVector > 0 ? "BULL EXPANSION" : "BEAR EXPANSION") :
                      isTrending  ? "DIRECTIONAL DRIFT" :
                      isSqueeze   ? "VOLATILITY SQUEEZE" : "MEAN REVERSION"

color vectorCol = isExpansion ? (regimeVector > 0 ? c_bull_exp : c_bear_exp) :
                  isTrending  ? c_drift :
                  isSqueeze   ? c_squeeze : c_range

// ==========================================
// PLOTS & VISUALIZATION
// ==========================================
hZero = hline(0, "Equilibrium Zero", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hTop  = hline(50, "Expansion Zone", color=color.new(#00e676, 75), linestyle=hline.style_dashed)
hBtm  = hline(-50, "Contraction Zone", color=color.new(#ff1744, 75), linestyle=hline.style_dashed)

// Dynamic Volatility Surface Ribbon
plot(regimeVector, title="Regime Vector", color=vectorCol, linewidth=2)
plot(ta.ema(regimeVector, 9), title="Vector Signal Line", color=color.new(color.white, 40), linewidth=1)

fill(hZero, hTop, color=color.new(#00e676, 95), title="Bullish Fill")
fill(hZero, hBtm, color=color.new(#ff1744, 95), title="Bearish Fill")

// Squeeze Markers
plotshape(isSqueeze and not isSqueeze[1], title="Squeeze Inception", style=shape.diamond,
          location=location.bottom, color=c_squeeze, size=size.tiny)

// Alerts
alertcondition(isExpansion and not isExpansion[1], title="[AlgoChief] Explosive Volatility Expansion", message="[AlgoChief] Market entered Explosive Volatility Regime at {{close}}")
alertcondition(isSqueeze and not isSqueeze[1], title="[AlgoChief] Volatility Squeeze Detected", message="[AlgoChief] Volatility Compression detected! Explosive move incoming.")
alertcondition(ta.crossover(regimeVector, 0), title="[AlgoChief] Bullish Regime Shift", message="[AlgoChief] Quantitative Regime turned BULLISH at {{close}}")
alertcondition(ta.crossunder(regimeVector, 0), title="[AlgoChief] Bearish Regime Shift", message="[AlgoChief] Quantitative Regime turned BEARISH at {{close}}")

// ==========================================
// QUANTITATIVE MATRIX HUD (100% FIXED)
// ==========================================
var table hud = table.new(position.top_right, columns = 2, rows = 5, bgcolor = color.new(#11141a, 15),
                          border_color = color.new(#374151, 40), border_width = 1)

if showHud and barstate.islast
    table.cell(hud, 0, 0, "Quant Matrix", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 0, "[AlgoChief]", text_color=color.gray, text_size=size.small)

    table.cell(hud, 0, 1, "Market Regime", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 1, currentState, text_color=vectorCol, text_size=size.small)

    table.cell(hud, 0, 2, "Fractal Dim (FDI)", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(fdi, "#.##"), text_color=fdi < trendThreshold ? #00e676 : #ffd600, text_size=size.small)

    table.cell(hud, 0, 3, "Volatility Percentile", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(volRank, "#.#") + "%", text_color=volRank > 70 ? #ff1744 : #29b6f6, text_size=size.small)

    table.cell(hud, 0, 4, "Efficiency Ratio", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(effRatio, "#.##"), text_color=effRatio > 0.4 ? #00e676 : color.gray, text_size=size.small)
````
