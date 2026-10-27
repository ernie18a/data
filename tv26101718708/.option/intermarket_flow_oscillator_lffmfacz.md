# Intermarket Flow Oscillator

- url: https://www.tradingview.com/script/lFFmfacz-Intermarket-Flow-Oscillator/
- type: indicator
- pine_id: PUB;5fae3b2624544cf8be04ddec3474ebf1
- version: 1.0

## Description

[i][b]Advanced Macro Regime Tracking & Apex Reversal Detection[/b][/i]

[b]What is the Intermarket Flow Oscillator (IFO)?[/b]
The Intermarket Flow Oscillator (IFO) is a quantitative momentum tool designed to track capital rotation between risk-on assets (growth, equities) and risk-off assets (defensives, bonds, safe havens). By utilizing advanced statistical normalization and John Ehlers' digital signal processing, the IFO visualizes structural market regimes and pinpoints high-probability exhaustion reversals.

Whether you are trading swing setups on the daily chart or monitoring intraday capital flows, the IFO acts as a macro compass to keep you on the right side of institutional money.

[b]The Mathematical Engine[/b]

Traditional spread indicators suffer from noise and asymmetric scaling. The IFO solves this using a two-step quantitative process:
[list]
[*][b]Z-Score Normalization: [/b]The script calculates the natural log ratio of a Risk Asset versus a Safe Haven asset, then applies a rolling Z-Score. This transforms the intermarket spread into a stationary stochastic process, making standard deviation thresholds mathematically reliable.
[*][b]John Ehlers' 2-Pole SuperSmoother:[/b] To eliminate high-frequency market noise without introducing the severe phase lag typical of moving averages, the Z-Score is passed through an advanced DSP filter.
[/list]
[b]How to Read the Signals[/b]
[list=1]
[*][b]Trend Shifts & Structural Regimes (The Zero-Line)[/b]
The smoothed oscillator crossing the zero equilibrium line indicates a macro shift in capital allocation.
[b]Green Cloud (IFO > 0): [/b]Structural Risk-On Regime. Institutions are accumulating risk/growth. Traders should look for long momentum setups and favor high-beta assets.
[b]Red Cloud (IFO < 0): [/b]Structural Risk-Off Regime. Capital is fleeing to safety. Traders should focus on cash preservation, defensive value, or short setups.

[*][b]Apex Mean-Reversion Turns (▲ and ▼)[/b]
The script calculates the first derivative (Velocity) of the smoothed capital flow. When the oscillator reaches extreme statistical exhaustion thresholds (default ±1.5 standard deviations) and the velocity flips, the IFO prints a high-contrast triangle.
[b]Bullish Apex (▲): [/b]Occurs deep in negative territory (panic/capitulation). Represents a mathematically optimal exhaustion point where selling pressure is dying. Excellent for buying the bottom in growth stocks.
[b]Bearish Apex (▼): [/b]Occurs high in positive territory (euphoria). Represents exhaustion in risk-taking and serves as an early warning to take profits or look for short entries.
[/list]
[b]Practical Trading Application: Sector Rotation (XLK vs. XLP)[/b]

While the default script pairs S&P 500 Futures (ES) against 10-Year Treasuries (ZN), the true power of the IFO shines in sector rotation.
[b]The Setup:[/b] Set the Risk Asset to XLK (Technology) and the Safe Haven to XLP (Consumer Staples).
[b]The Logic: [/b]XLK represents high-beta, duration-sensitive growth (Apple, Microsoft, Nvidia). XLP represents inelastic consumer demand (Procter & Gamble, Walmart). This spread is the ultimate risk-on/risk-off gauge.

[b]Key Features & Customization[/b]
[list]
[*][b]Customizable Pairs:[/b] Fully adjustable inputs to test different macro pairs (e.g., BTC vs. Gold, BTCUSDT.P vs. USDT, Discretionary vs. Utilities, High Yield Bonds vs. Treasuries).
[*][b]Dynamic Coloring:[/b] The oscillator line shifts between bright/faded colors based on momentum velocity, giving you a visual cue before a crossover even happens.
[/list]

## Source Code

````pine
//@version=6
indicator('Intermarket Flow Oscillator', shorttitle = 'IFO', precision = 2, overlay = false)

// ═══════════════════════════════════════════════════════════════════════
// 1. INPUTS & CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════
grp_sets = "DSP & Statistical Engine Settings"
z_length = input.int(50, title = 'Z-Score Normalization Period', minval = 10, maxval = 200, group = grp_sets, tooltip = "Lookback window for statistical mean-standard deviation scaling.")
smooth_len = input.int(8, title = 'SuperSmoother Period', minval = 2, maxval = 50, group = grp_sets, tooltip = "John Ehlers' 2-Pole filter cutoff length to eliminate high-frequency noise without phase lag.")
threshold_extreme = input.float(1.5, title = "Apex Reversal Band (SD)", minval = 0.5, maxval = 3.0, step = 0.1, group = grp_sets, tooltip = "Standard deviation threshold to identify extreme overextended money flow.")
showApexBg = input.bool(false, 'Show Apex Background Color', group = grp_sets)
var color c_bullish = input.color(color.rgb(76, 175, 79, 30), 'Bullish Signals Color', group = 'Colors', inline = 'reversal')
var color c_bearish = input.color(color.rgb(255, 82, 82, 30), 'Bearish Signals Color', group = 'Colors', inline = 'reversal')

grp_assets = "Intermarket Reference Assets"
sym_risk = input.symbol('CME_MINI:ES1!', title = 'Risk Asset (e.g. Stocks/Crypto)', group = grp_assets, tooltip = "Asset that outperforms during expansion / inflation / risk-on regimes.\nDefault is S&P 500 Futures.")
sym_safe = input.symbol('CBOT:ZN1!', title = 'Safe Haven (e.g. Bonds/Gold)', group = grp_assets, tooltip = "Asset that attracts capital during contraction / deflation / risk-off regimes.\nDefault is 10-Year US Treasury Futures.")

// ═══════════════════════════════════════════════════════════════════════
// 2. DATA ACQUISITION & SAFEGUARDING
// ═══════════════════════════════════════════════════════════════════════
market_risk = request.security(sym_risk, timeframe.period, close)
market_safe = request.security(sym_safe, timeframe.period, close)

// Prevent division by zero or NaN values
float risk_val = nz(market_risk) > 0 ? market_risk : 1.0
float safe_val = nz(market_safe) > 0 ? market_safe : 1.0

// ═══════════════════════════════════════════════════════════════════════
// 3. STATISTICAL STANDARDIZATION (Z-SCORE)
// ═══════════════════════════════════════════════════════════════════════
// Use Natural Log Spread to ensure symmetric scaling of relative returns
float raw_ratio = math.log(risk_val / safe_val)

// Compute rolling Z-Score to establish a stationary stochastic process
float ratio_mean = ta.sma(raw_ratio, z_length)
float ratio_std = ta.stdev(raw_ratio, z_length)
float z_score = ratio_std > 0 ? (raw_ratio - ratio_mean) / ratio_std : 0.0

// ═══════════════════════════════════════════════════════════════════════
// 4. JOHN EHLERS' 2-POLE SUPERSMOOTHER FILTER
// ═══════════════════════════════════════════════════════════════════════
f_supersmoother(float src, float length) =>
    float clean_len = math.max(2.0, length)
    float a1 = math.exp(-math.sqrt(2.0) * math.pi / clean_len)
    float b1 = 2.0 * a1 * math.cos(math.sqrt(2.0) * math.pi / clean_len)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    var float ss = 0.0
    ss := c1 * (src + nz(src[1], src)) / 2.0 + c2 * nz(ss[1], src) + c3 * nz(ss[2], src)
    ss

// Smooth the non-stationary Z-Score to isolate capital flow trend
float smoothed_z = f_supersmoother(z_score, smooth_len)

// ═══════════════════════════════════════════════════════════════════════
// 5. MOMENTUM DERIVATIVES & APEX DETECTION
// ═══════════════════════════════════════════════════════════════════════
// Velocity (1st derivative)
float velocity = smoothed_z - nz(smoothed_z[1], smoothed_z)

// Unconditionally evaluate stateful crossover/crossunder signals in the global scope
bool crossover_vel  = ta.crossover(velocity, 0.0)
bool crossunder_vel = ta.crossunder(velocity, 0.0)
bool crossover_z    = ta.crossover(smoothed_z, 0.0)
bool crossunder_z   = ta.crossunder(smoothed_z, 0.0)

// Apex Reversal signals (when velocity crosses zero at standard deviation extremes)
bool bull_apex = (smoothed_z < -threshold_extreme) and crossover_vel
bool bear_apex = (smoothed_z > threshold_extreme) and crossunder_vel

// ═══════════════════════════════════════════════════════════════════════
// 6. VISUAL RENDERING ENGINE
// ═══════════════════════════════════════════════════════════════════════
// Premium Institutional Color Palette (Google TensorFlow style)
color col_fast_bull = #009988
color col_slow_bull = color.new(#009988, 50)
color col_fast_bear = #CC3311
color col_slow_bear = color.new(#CC3311, 50)

color col_osc = color.gray
if smoothed_z >= 0.0
    col_osc := velocity > 0.0 ? col_fast_bull : col_slow_bull
else
    col_osc := velocity < 0.0 ? col_fast_bear : col_slow_bear

// Envelopes & Thresholds
hline(2.0, "Extreme Risk-On (+2.0 SD)", color = color.new(#CC3311, 60), linestyle = hline.style_dotted)
hline(1.5, "Risk-On Exhaustion (+1.5 SD)", color = color.new(#CC3311, 40), linestyle = hline.style_dashed)
hline(1.0, "Mild Risk-On (+1.0 SD)", color = color.new(color.gray, 60), linestyle = hline.style_solid)
p_zero = plot(0.0, color = color.new(color.gray, 40), title = "Equilibrium (0.0 Line)", linewidth = 2)
hline(-1.0, "Mild Risk-Off (-1.0 SD)", color = color.new(color.gray, 60), linestyle = hline.style_solid)
hline(-1.5, "Risk-Off Exhaustion (-1.5 SD)", color = color.new(#009988, 40), linestyle = hline.style_dashed)
hline(-2.0, "Extreme Risk-Off (-2.0 SD)", color = color.new(#009988, 60), linestyle = hline.style_dotted)

// Main Oscillator Plot
p_osc = plot(smoothed_z, color = col_osc, title = "Ehlers Flow Oscillator (Z-Score)", linewidth = 2)

// Cloud Regime Fill
color col_cloud = smoothed_z > 0.0 ? color.new(#009988, 85) : color.new(#CC3311, 85)
fill(p_osc, p_zero, color = col_cloud, title = "Regime Cloud")

// Signal Shapes (Apex Turn Triangles)
plotshape(bull_apex, title = "Bullish Apex Turn", style = shape.triangleup, location = location.bottom, color = col_fast_bull, size = size.tiny)
plotshape(bear_apex, title = "Bearish Apex Turn", style = shape.triangledown, location = location.top, color = col_fast_bear, size = size.tiny)

// Background Highlights using Curated Colors (Transparent)
bgcolor(showApexBg and bull_apex ? color.new(c_bullish, 92) : showApexBg and bear_apex ? color.new(c_bearish, 92) : na, title = 'Apex Reversal Background', force_overlay = true)

// ═══════════════════════════════════════════════════════════════════════
// 7. MULTI-REGIME ALERTS
// ═══════════════════════════════════════════════════════════════════════
alertcondition(bull_apex, title = "Bullish Apex Reversal (Risk-Off Bottoming)", message = "EIFO: Capital Flow is turning bullish at extreme exhaustion!")
alertcondition(bear_apex, title = "Bearish Apex Reversal (Risk-On Peak)", message = "EIFO: Capital Flow is turning bearish at extreme exhaustion!")
alertcondition(crossover_z, title = "Trend Shift to Risk-On", message = "EIFO: Capital Flow crossed above 0 (Risk-On expansion)")
alertcondition(crossunder_z, title = "Trend Shift to Risk-Off", message = "EIFO: Capital Flow crossed below 0 (Risk-Off expansion)")
````
