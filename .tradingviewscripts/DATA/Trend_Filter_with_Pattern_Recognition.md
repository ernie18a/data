<!-- tradingview-pine-id: PUB;403b0e4c65a94b79aae8fed85734633e -->
<!-- tradingviewscripts-format: 1 -->
# Trend Filter with Pattern Recognition

Source: https://www.tradingview.com/script/sr0scAV5-Wavelet-Trend-ML-Integration-Alpha-Extract/

## Description

Alpha-Extract Volatility Quality Indicator

The Alpha-Extract Volatility Quality (AVQ) Indicator provides traders with deep insights into market volatility by measuring the directional strength of price movements. This sophisticated momentum-based tool helps identify overbought and oversold conditions, offering actionable buy and sell signals based on volatility trends and standard deviation bands.

🔶 CALCULATION

The indicator processes volatility quality data through a series of analytical steps:

[*]Bar Range Calculation: Measures true range (TR) to capture price volatility.
[*]Directional Weighting: Applies directional bias (positive for bullish candles, negative for bearish) to the true range.
[*]VQI Computation: Uses an exponential moving average (EMA) of weighted volatility to derive the Volatility Quality Index (VQI).
[*]Smoothing: Applies an additional EMA to smooth the VQI for clearer signals.
[*]Normalization: Optionally normalizes VQI to a -100/+100 scale based on historical highs and lows.
[*]Standard Deviation Bands: Calculates three upper and lower bands using standard deviation multipliers for volatility thresholds.
[*]Signal Generation: Produces overbought/oversold signals when VQI reaches extreme levels (±200 in normalized mode). 

Formula:

[*]Bar Range = True Range (TR)
[*]Weighted Volatility = Bar Range × (Close > Open ? 1 : Close < Open ? -1 : 0)
[*]VQI Raw = EMA(Weighted Volatility, VQI Length)
[*]VQI Smoothed = EMA(VQI Raw, Smoothing Length)
[*]VQI Normalized = ((VQI Smoothed - Lowest VQI) / (Highest VQI - Lowest VQI) - 0.5) × 200
[*]Upper Band N = VQI Smoothed + (StdDev(VQI Smoothed, VQI Length) × Multiplier N)
[*]Lower Band N = VQI Smoothed - (StdDev(VQI Smoothed, VQI Length) × Multiplier N) 

🔶 DETAILS

Visual Features:

[*]VQI Plot: Displays VQI as a line or histogram (lime for positive, red for negative).
[*]Standard Deviation Bands: Plots three upper and lower bands (teal for upper, grayscale for lower) to indicate volatility thresholds.
[*]Reference Levels: Horizontal lines at 0 (neutral), +100, and -100 (in normalized mode) for context.
[*]Zone Highlighting: Overbought (⋎ above bars) and oversold (⋏ below bars) signals for extreme VQI levels (±200 in normalized mode).
[*]Candle Coloring: Optional candle overlay colored by VQI direction (lime for positive, red for negative). 
[*]Interpretation:
[*]VQI ≥ 200 (Normalized): Overbought condition, strong sell signal.
[*]VQI 100–200: High volatility, potential selling opportunity.
[*]VQI 0–100: Neutral bullish momentum.
[*]VQI 0 to -100: Neutral bearish momentum.
[*]VQI -100 to -200: High volatility, strong bearish momentum.
[*]VQI ≤ -200 (Normalized): Oversold condition, strong buy signal. 

https://www.tradingview.com/x/sHjyBiNY/
🔶 EXAMPLES 

[*]Overbought Signal Detection: When VQI exceeds 200 (normalized), the indicator flags potential market tops with a red ⋎ symbol.
[*]Example: During strong uptrends, VQI reaching 200 has historically preceded corrections, allowing traders to secure profits. 
[*]Oversold Signal Detection: When VQI falls below -200 (normalized), a lime ⋏ symbol highlights potential buying opportunities.
[*]Example: In bearish markets, VQI dropping below -200 has marked reversal points for profitable long entries. 
[*]Volatility Trend Tracking: The VQI plot and bands help traders visualize shifts in market momentum.
[*]Example: A rising VQI crossing above zero with widening bands indicates strengthening bullish momentum, guiding traders to hold or enter long positions. 
[*]Dynamic Support/Resistance: Standard deviation bands act as dynamic volatility thresholds during price movements.
[*]Example: Price reversals often occur near the third standard deviation bands, providing reliable entry/exit points during volatile periods. 

https://www.tradingview.com/x/anUutVYZ/
🔶 SETTINGS

Customization Options:

[*]VQI Length: Adjust the EMA period for VQI calculation (default: 14, range: 1–50).
[*]Smoothing Length: Set the EMA period for smoothing (default: 5, range: 1–50).
[*]Standard Deviation Multipliers: Customize multipliers for bands (defaults: 1.0, 2.0, 3.0).
[*]Normalization: Toggle normalization to -100/+100 scale and adjust lookback period (default: 200, min: 50).
[*]Display Style: Switch between line or histogram plot for VQI.
[*]Candle Overlay: Enable/disable VQI-colored candles (lime for positive, red for negative).
 
The Alpha-Extract Volatility Quality Indicator empowers traders with a robust tool to navigate market volatility. By combining directional price range analysis with smoothed volatility metrics, it identifies overbought and oversold conditions, offering clear buy and sell signals. The customizable standard deviation bands and optional normalization provide precise context for market conditions, enabling traders to make informed decisions across various market cycles.

---

## Source Code

````pine
//@version=6
indicator("Trend Filter with Pattern Recognition", overlay=false)

// ===========================================================================
// HIGH-PASS FILTER INPUTS
// ============================================================================
shortLength = input(12, "Short Scale Length", group="High-Pass Filter Settings")
longLength = input(23, "Long Scale Length", group="High-Pass Filter Settings")
smoothing = input(8, "Final Signal Smoothing", group="Signal Processing")
lookback = input.int(1000, "Normalization Lookback", maxval=1000, minval=1, step=1, group="Signal Processing")
atrLength = input(8, "ATR Length", group="High-Pass Filter Settings")

// Filter controls
useWavelet = input.bool(true, "Enable High-Pass Filter", group="High-Pass Filter Settings")
noiseReduction = input.bool(true, "Enable Noise Reduction", group="High-Pass Filter Settings")
wnMin = input(1, "NoiseR Min Length", group="High-Pass Filter Settings")
wnMax = input(2, "NoiseR Max Length", group="High-Pass Filter Settings")

// =============================================================================
// BINARY CLASSIFIER INPUTS
// =============================================================================
enableAI = input.bool(true, "Enable Binary Classifier", group="Binary Classifier")
adaptivePeriod = input(50, "Adaptive Normalization Period", group="Binary Classifier")
adaptationRate = input.float(0.08, 'Learning Rate', step=0.01, maxval=0.15, group="Binary Classifier")

// Binary Classifier Engineering Parameters
momentum_period = input.int(29, "Momentum Detector Length", group="Binary Classifier Features")
volatility_period = input.int(45, "Volatility Detector Length", group="Binary Classifier Features")
trend_strength_period = input.int(35, "Trend Strength Length", group="Binary Classifier Features")
oscillation_period = input.int(35, "Oscillation Detector Length", group="Binary Classifier Features")
velocity_period = input(30, "Price Velocity Length", group="Binary Classifier Features")
resistance_factor = input.float(3.2, "Dynamic Resistance Factor", step=0.1, group="Binary Classifier Features")
resistance_period = input.int(2, "Resistance Detection Period", step=1, group="Binary Classifier Features")

// Binary Classifier Weights (Synaptic Strengths)
alpha_momentum = 1
beta_volatility = 4
gamma_trend = 1
delta_oscillation = 2
epsilon_velocity = 5
zeta_resistance = 4

// Color options
upper_col = input.color(#00b35f, "Up Color", inline = "colors", group="Display")
lower_col = input.color(#cf1059, "Down Color", inline = "colors", group="Display")

// =============================================================================
// HORIZONTAL REFERENCE LINES SETTINGS
// =============================================================================
showHLines = input.bool(true, "Show Horizontal Reference Lines", group="Display")
hlineColor = input.color(color.new(color.gray, 70), "Reference Line Color", group="Display")
hlineStyle = input.string("Dashed", "Reference Line Style", options=["Solid", "Dashed", "Dotted"], group="Display")

// =============================================================================
// HIGH-PASS FILTER FUNCTIONS & CALCULATIONS
// =============================================================================
// ATR Calculation
atr = ta.atr(atrLength)

// High-pass filter function
pi = 3.14159265359
highPassFilter(src, len) =>
    alpha = (1 - math.sin(2 * pi / len)) / math.cos(2 * pi / len)
    hp = 0.0
    hp := (1 - alpha/2) * (src - src[1]) + (1 - alpha) * nz(hp[1])
    ta.ema(hp, 3)

// Multi-scale high-pass filtering with enhanced sensitivity
fastComponent = useWavelet ? highPassFilter(close, shortLength) : ta.ema(close, shortLength)
slowComponent = useWavelet ? highPassFilter(close, longLength) : ta.ema(close, longLength)

// Enhanced raw signal calculation to amplify scale differences
scaleRatio = longLength / shortLength
rawSignal = (fastComponent - slowComponent) * scaleRatio

// Noise reduction
wn(src) =>
    maFast = ta.ema(src, wnMin)
    maSlow = ta.ema(src, wnMax)
    noiseReduction ? (maFast + maSlow) / 2 : src

smoothedSignal = wn(rawSignal)

// Normalization with scale preservation
atrAdjustedSignal = smoothedSignal / math.max(atr * scaleRatio, 0.001)
absMax = ta.highest(math.abs(atrAdjustedSignal), lookback)
filterNormalized = atrAdjustedSignal / math.max(absMax, 0.001)
filterNormalized := math.min(math.max(filterNormalized, -1), 1)

// =============================================================================
// BINARY CLASSIFIER FUNCTIONS & CALCULATIONS
// =============================================================================

// Adaptive Data Standardization Engine
standardize_data(source_data) =>
    mean_baseline = ta.sma(source_data, adaptivePeriod)
    deviation = ta.stdev(source_data, adaptivePeriod)
    standardized = (source_data - mean_baseline) / math.max(deviation, 0.0001)
    standardized

// Sigmoid Activation Function
neural_activation(f1, f2, f3, f4, f5, f6, bias, w1, w2, w3, w4, w5, w6) =>
    neural_input = bias + w1 * f1 + w2 * f2 + w3 * f3 + w4 * f4 + w5 * f5 + w6 * f6
    activation_output = 1 / (1 + math.exp(-neural_input))
    activation_output

// Prediction Error Calculator 
prediction_error(actual_target, predicted_output) =>
    safe_predicted = math.max(math.min(predicted_output, 0.9999), 0.0001)
    error = -actual_target * math.log(safe_predicted) - (1 - actual_target) * math.log(1 - safe_predicted)
    error

// Feature Engineering Module
momentum_detector = ta.rsi(close, momentum_period)
volatility_detector = ta.cci(hlc3, volatility_period)
[trend_positive, trend_negative, _] = ta.dmi(trend_strength_period, 10)

// Custom Oscillation Detector (Enhanced Aroon)
highest_position(length) =>
    bars_since_high = ta.highestbars(high, length)
    oscillation_up = ((length + bars_since_high) / length) * 100
    oscillation_up

lowest_position(length) =>
    bars_since_low = ta.lowestbars(low, length)
    oscillation_down = ((length + bars_since_low) / length) * 100
    oscillation_down

oscillation_up = highest_position(oscillation_period)
oscillation_down = lowest_position(oscillation_period)

// Price Velocity Analyzer
velocity_fast = ta.ema(close, velocity_period)
velocity_slow = ta.ema(close, velocity_period - 10)

// Dynamic Resistance Detection System
[resistance_level, resistance_direction] = ta.supertrend(resistance_factor, resistance_period)

// Binary Classifier Weight Management System
var float bias_node = 1.0
var float learning_adj_momentum = 0.0
var float learning_adj_volatility = 0.0
var float learning_adj_trend = 0.0
var float learning_adj_oscillation = 0.0
var float learning_adj_velocity = 0.0
var float learning_adj_resistance = 0.0

// Target Variable Generation 
market_direction = standardize_data(close) > 0 ? 1 : 0

// Feature Vector Construction 
feature_momentum = momentum_detector > 50 ? 1 : 0
feature_volatility = 0.5
if ta.crossover(volatility_detector, 100)
    feature_volatility := 1
if ta.crossunder(volatility_detector, -100)
    feature_volatility := 0

feature_trend = trend_positive > trend_negative ? 1 : 0
feature_oscillation = oscillation_up > oscillation_down ? 1 : 0
feature_velocity = velocity_fast > velocity_slow ? 1 : 0
feature_resistance = resistance_direction == -1 ? 1 : 0

// Binary Classifier Processing
ai_prediction = 0.0
if enableAI
    current_momentum = alpha_momentum + learning_adj_momentum
    current_volatility = beta_volatility + learning_adj_volatility
    current_trend = gamma_trend + learning_adj_trend
    current_oscillation = delta_oscillation + learning_adj_oscillation
    current_velocity = epsilon_velocity + learning_adj_velocity
    current_resistance = zeta_resistance + learning_adj_resistance
    
    // Forward Pass: Generate Initial Prediction
    initial_prediction = neural_activation(feature_momentum, feature_volatility, feature_trend, 
                                         feature_oscillation, feature_velocity, feature_resistance,
                                         bias_node, current_momentum, current_volatility, 
                                         current_trend, current_oscillation, 
                                         current_velocity, current_resistance)
    
    // Backward Pass: Weight Adjustment
    prediction_gradient = initial_prediction - market_direction
    learning_adj_momentum := learning_adj_momentum - adaptationRate * prediction_gradient * feature_momentum
    learning_adj_volatility := learning_adj_volatility - adaptationRate * prediction_gradient * feature_volatility
    learning_adj_trend := learning_adj_trend - adaptationRate * prediction_gradient * feature_trend
    learning_adj_oscillation := learning_adj_oscillation - adaptationRate * prediction_gradient * feature_oscillation
    learning_adj_velocity := learning_adj_velocity - adaptationRate * prediction_gradient * feature_velocity
    learning_adj_resistance := learning_adj_resistance - adaptationRate * prediction_gradient * feature_resistance
    
    // Final Prediction with Adapted Weights
    final_prediction = neural_activation(feature_momentum, feature_volatility, feature_trend,
                                       feature_oscillation, feature_velocity, feature_resistance,
                                       bias_node, current_momentum, current_volatility,
                                       current_trend, current_oscillation,
                                       current_velocity, current_resistance)
    
    // Transform to Bipolar Signal Range (-1 to 1)
    ai_prediction := (final_prediction - 0.5) * 2

// =============================================================================
// SIGNAL FUSION
// =============================================================================

// Calculate raw final signal based on enabled components
rawFinalSignal = 0.0

if useWavelet and enableAI
    rawFinalSignal := (filterNormalized + ai_prediction) / 2
else if useWavelet and not enableAI
    rawFinalSignal := filterNormalized
else if not useWavelet and enableAI
    rawFinalSignal := ai_prediction
else
    // Neither enabled: fallback to simple momentum
    rawFinalSignal := ta.mom(close, 14) / close

// APPLY SMOOTHING TO ENTIRE FINAL SIGNAL 
smoothedFinalSignal = ta.ema(rawFinalSignal, smoothing)

// ENHANCED ADAPTIVE NORMALIZATION 
recentVolatility = ta.stdev(smoothedFinalSignal, lookback)
longTermVolatility = ta.stdev(smoothedFinalSignal, lookback * 2)
adaptiveScale = recentVolatility / math.max(longTermVolatility, 0.0001)

// Apply adaptive scaling -
finalSignal = smoothedFinalSignal * adaptiveScale
finalSignal := math.min(math.max(finalSignal, -2), 2)  

// =============================================================================
// HORIZONTAL REFERENCE LINES 
// =============================================================================

// Convert string input to line style condition
lineCondition = switch hlineStyle
    "Solid" => true
    "Dashed" => bar_index % 4 <= 1
    "Dotted" => bar_index % 2 == 0
    => true

// Use the actual user-selected color with show/hide logic
refLineColor = showHLines and lineCondition ? hlineColor : na
zeroLineColor = showHLines and lineCondition ? color.new(hlineColor, 30) : na

// Plot reference lines using user's color and style choices
plot(showHLines ? 1.0 : na, "Upper Extreme", color = refLineColor, linewidth=1)
plot(showHLines ? 0.75 : na, "Strong Bullish", color = refLineColor, linewidth=1)
plot(showHLines ? 0.5 : na, "Bullish Zone", color = refLineColor, linewidth=1)
plot(showHLines ? 0.25 : na, "Weak Bullish", color = refLineColor, linewidth=1)
plot(showHLines ? 0 : na, "Zero Line", color = zeroLineColor, linewidth=2)
plot(showHLines ? -0.25 : na, "Weak Bearish", color = refLineColor, linewidth=1)
plot(showHLines ? -0.5 : na, "Bearish Zone", color = refLineColor, linewidth=1)
plot(showHLines ? -0.75 : na, "Strong Bearish", color = refLineColor, linewidth=1)
plot(showHLines ? -1.0 : na, "Lower Extreme", color = refLineColor, linewidth=1)

// =============================================================================
// VISUALIZATION WITH GRADIENT FILL 
// =============================================================================

// Color logic: Green above zero, red below zero  
trend_col = finalSignal >= 0 ? upper_col : lower_col
trend_col1 = finalSignal >= 0 ? upper_col : lower_col

// Plot colored candles based on signal direction
plotcandle(open, high, low, close,
           title = 'Signal Candles',
           color = trend_col,
           wickcolor = trend_col,
           bordercolor = trend_col, force_overlay=true)

// Plot two lines like original Kalman-style indicator
p1 = plot(finalSignal, "Signal", color = trend_col1)
p2 = plot(0, "Zero Line", linewidth = 2, color = trend_col)

// ORIGINAL GRADIENT FILL STYLE 
fill(p1, p2, finalSignal, 0, na, color.new(trend_col, 70))

// Signal arrows for crossovers
// Bullish Signal (below bar)
plotshape(finalSignal > 0 and finalSignal[1] <= 0, 
  style=shape.labelup, 
  location=location.belowbar, 
  color=upper_col, 
  textcolor=color.white,
  size=size.tiny,
  text="︿",
  title="Bullish Signal", force_overlay=true)

// Bearish Signal (above bar)  
plotshape(finalSignal < 0 and finalSignal[1] >= 0, 
  style=shape.labeldown,
  location=location.abovebar, 
  color=lower_col, 
  textcolor=color.white,
  size=size.tiny,
  text="﹀",
  title="Bearish Signal", force_overlay=true)
// =============================================================================
// INTELLIGENT ALERT SYSTEM
// =============================================================================
alertcondition(finalSignal > 0 and finalSignal[1] <= 0, "Bullish Signal", "Bullish Signal Detected")
alertcondition(finalSignal < 0 and finalSignal[1] >= 0, "Bearish Signal", "Bearish Signal Detected")
````
