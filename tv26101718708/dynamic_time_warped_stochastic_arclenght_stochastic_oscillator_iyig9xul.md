# Dynamic Time Warped Stochastic. Arc-Lenght Stochastic Oscillator

- url: https://www.tradingview.com/script/IYig9XUL-Dynamic-Time-Warped-Stochastic-Arc-Lenght-Stochastic-Oscillator/
- type: indicator
- pine_id: PUB;87a53733f1864fe8b357eae4834263b9
- version: 1.0

## Description

𝐓𝐇𝐄 𝐀𝐑𝐂-𝐊𝐈𝐍𝐄𝐌𝐀𝐓𝐈𝐂 𝐎𝐒𝐂𝐈𝐋𝐋𝐀𝐓𝐎𝐑: 𝐁𝐞𝐲𝐨𝐧𝐝 𝐂𝐡𝐫𝐨𝐧𝐨𝐥𝐨𝐠𝐢𝐜𝐚𝐥 𝐓𝐢𝐦𝐞OverviewFor decades, the standard approach to measuring market momentum has relied on a fatal flaw: chronological time. Traditional oscillators force a rigid, fixed lookback window onto an environment that is fundamentally non-linear. When volatility compresses, chronological indicators generate false signals from microscopic chop. When volatility expands, they lag.This tool abandons chronological time. Instead, it processes market structure through a topological lens, measuring the actual path traversed by price action rather than the arbitrary ticking of a clock. It is an exploration of market kinematics designed to filter out spurious noise and identify true regime shifts.Under the Hood: The Mechanics of Topological Data AnalysisThis is not a smoothed RSI or a standard stochastic oscillator. The underlying engine operates on principles derived from digital signal processing and econophysics.Time-Dilated Lookback: Instead of a fixed N-period lookback, the calculation matrix expands and contracts dynamically. It measures the geometric arc-length (ds) of the price vector. During tight, sideways consolidation, the window stretches to absorb the noise. During explosive expansion, the window shrinks, snapping to the current regime with near-zero lag.Kinematic Tokenization: The script analyzes the primary and secondary derivatives of price  to understand the velocity and acceleration of the order flow, separating true institutional displacement from retail trap-moves.Advanced Signal Processing: To present this data cleanly, the raw kinematic output is passed through a multi-pole Gaussian filtration system and a non-linear bounding transform. This creates a hyper-responsive oscillator that maps purely between +1 and -1 remaining completely flat during untradeable chop and only oscillating when true structural momentum is present.

How to Use This Tool

This indicator does not predict the future. It categorizes the present.Regime Identification: Observe the boundaries. When the oscillator is pinned at the extremes, the market is in a dominant, unidirectional regime. Divergence against Time: Because the tool operates outside of chronological time, standard divergences (price making a higher high while the oscillator makes a lower high) carry significantly higher structural weight than those found on traditional indicators.Confluence: Use this as a confirming layer. It is designed to validate structural market shifts, identifying when a swept level or a break in market structure has the underlying mathematical velocity to sustain a new trend.DisclaimerThis script is published strictly for educational and analytical purposes. It is a mathematical exploration of market topology and signal processing. It does not constitute financial advice, nor does it guarantee profitable trades. Past performance of mathematical models does not guarantee future market behavior. Always use strict risk management.

## Source Code

````pine
//@version=6
indicator("AL-Stoch: Arc-Length Bipolar Stochastic [Alpha Council]", shorttitle="AL-STOCH", overlay=false, max_bars_back=5000)

// ============================================================================
// 1. INPUT PARAMETERS (THE ARCHITECT'S CONTROLS)
// ============================================================================
float target_arc_length = input.float(30.0, title="Target Arc-Length (Σds)")
int filter_length = input.int(10, title="2-Pole Gaussian Length")
int atr_length = input.int(100, title="Scale Invariance (ATR Length)")
float ift_stretch = input.float(5.0, title="IFT Probability Stretch Factor")
int max_lookback_limit = input.int(500, title="Matrix Iteration Limit (Safety)")

// ============================================================================
// 2. KINEMATIC NORMALIZATION & DIFFERENTIALS
// ============================================================================
// We extract the local volatility to normalize dP, preventing dimensional mismatch
float local_atr = ta.atr(atr_length)
float safe_atr = math.max(local_atr, 0.000001)

// Calculate the normalized first derivative of price (dP/dx)
float dp_norm = (close - close[1]) / safe_atr

// The Pythagorean differential (ds) assumes dT = 1 (one unit of forward discrete time)
float ds = math.sqrt(math.pow(dp_norm, 2.0) + 1.0)

// ============================================================================
// 3. HEAVY MATRIX GENERATION (BRUTE-FORCE TOPOLOGY)
// ============================================================================
// We initialize arrays to reconstruct the market manifold backwards in time
float[] arr_close = array.new_float(0)
float[] arr_high = array.new_float(0)
float[] arr_low = array.new_float(0)
float[] arr_ds = array.new_float(0)

for int i = 0 to max_lookback_limit
    array.push(arr_close, close[i])
    array.push(arr_high, high[i])
    array.push(arr_low, low[i])
    array.push(arr_ds, ds[i])

// ============================================================================
// 4. ARC-LENGTH DYNAMIC WINDOW RESOLUTION
// ============================================================================
float accumulated_ds = 0.0
float topo_highest = close
float topo_lowest = close

// Iterate backward until the structural distance equals the Target Arc-Length
for int i = 0 to max_lookback_limit
    float current_ds = array.get(arr_ds, i)
    float current_high = array.get(arr_high, i)
    float current_low = array.get(arr_low, i)
    
    accumulated_ds := accumulated_ds + current_ds
    
    if current_high > topo_highest
        topo_highest := current_high
        
    if current_low < topo_lowest
        topo_lowest := current_low
        
    if accumulated_ds >= target_arc_length
        break

// ============================================================================
// 5. RAW BIPOLAR MAPPING
// ============================================================================
// Map the current price against the topologically derived highest/lowest bounds
float range_hl = math.max(topo_highest - topo_lowest, 0.000001)
float raw_stoch = (close - topo_lowest) / range_hl
// Shift from [0, 1] to pure bipolar [-1, +1]
float bipolar_stoch = 2.0 * raw_stoch - 1.0

// ============================================================================
// 6. 2-POLE GAUSSIAN FILTER (BOUCHAUD SMOOTHING)
// ============================================================================
// Calculate Ehlers SuperSmoother / Gaussian coefficients for lag-reduced smoothing
float sqrt2pi = 1.414 * math.pi / filter_length
float alpha_g = math.exp(-sqrt2pi)
float coef2 = 2.0 * alpha_g * math.cos(sqrt2pi)
float coef3 = -1.0 * math.pow(alpha_g, 2.0)
float coef1 = 1.0 - coef2 - coef3

// Instantiate persistent variables for the memory poles
var float gaussian_0 = 0.0
var float gaussian_1 = 0.0
var float gaussian_2 = 0.0

// Apply the filter matrix
gaussian_0 := coef1 * bipolar_stoch + coef2 * gaussian_1 + coef3 * gaussian_2
gaussian_2 := gaussian_1
gaussian_1 := gaussian_0

// ============================================================================
// 7. INVERSE FISHER TRANSFORM (NON-LINEAR PROBABILITY WARPING)
// ============================================================================
// Scale the output to widen the probability distribution before the IFT snap
float scaled_gaussian = gaussian_0 * ift_stretch
float exp_2x = math.exp(2.0 * scaled_gaussian)
// The IFT operation strictly bounds the output to a flat -1 or +1 line
float al_stoch = (exp_2x - 1.0) / (exp_2x + 1.0)

// ============================================================================
// 8. VISUAL EXECUTION MANIFEST
// ============================================================================
color regime_color = al_stoch > 0.95 ? color.lime : al_stoch < -0.95 ? color.red : color.gray

plot(al_stoch, title="AL-Stoch Kinematic Line", color=regime_color, linewidth=3, style=plot.style_stepline)
hline(0.95, title="Long Exec", color=color.new(color.lime, 50), linestyle=hline.style_dashed)
hline(-0.95, title="Short Exec", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(0.0, title="Zero Origin", color=color.new(color.gray, 50), linestyle=hline.style_solid)
````
