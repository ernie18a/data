<!-- tradingview-pine-id: PUB;673af938de22407db19c6c280007a724 -->
<!-- tradingviewscripts-format: 1 -->
# EVaR Indicator and Position Sizing

Source: https://www.tradingview.com/script/c2fZXJII-EVaR-Indicator-and-Position-Sizing/

## Description

The Problem:
Financial markets consistently show "fat-tailed" distributions where extreme events occur with  higher frequency than predicted by normal distributions (Gaussian or even log-normal). These fat tails manifest in sudden price crashes, volatility spikes, and black swan events that traditional risk measures like volatility can underestimate. Standard deviation and conventional VaR calculations assume normally distributed returns, leaving traders vulnerable to severe drawdowns during market stress.

Cryptocurrencies and volatile instruments display particularly pronounced fat-tailed behavior, with extreme moves occurring 5-10 times more frequently than normal distribution models would predict. This reality demands a more sophisticated approach to risk measurement and position sizing.

The Solution: Entropic Value at Risk (EVAR)
EVaR addresses these limitations by incorporating principles from statistical mechanics and information theory through Tsallis entropy. This advanced approach captures the non-linear dependencies and power-law distributions characteristic of real financial markets.
Entropy is more adaptive than standard deviations and volatility measures. 

I was inspired to create this indicator after reading the paper "[The End of Mean-Variance? Tsallis Entropy Revolutionises Portfolio Optimisation in Cryptocurrencies](https://www.mdpi.com/1911-8074/18/2/77)" by by Sana Gaied Chortane  and Kamel Naoui.

Key advantages of EVAR over traditional risk measures:

[*]Superior tail risk capture: More accurately quantifies the probability of extreme market moves
[*]Adaptability to market regimes: Self-calibrates to changing volatility environments
[*]Non-parametric flexibility: Makes less assumptions about the underlying return distribution
[*]Forward-looking risk assessment: Better anticipates potential market changes (just look at the charts :)

Mathematically, EVAR is defined as:
EVAR_α(X) = inf_{z>0} {z * log(1/α * M_X(1/z))}
Where the moment-generating function is calculated using q-exponentials rather than conventional exponentials, allowing precise modeling of fat-tailed behavior.

Technical Implementation
This indicator implements EVAR through a q-exponential approach from Tsallis statistics:

[*]Returns Calculation: Price returns are calculated over the lookback period
[*]Moment Generating Function: Approximated using q-exponentials to account for fat tails
[*]EVAR Computation: Derived from the MGF and confidence parameter
[*]Normalization: Scaled to [0-1] for intuitive visualization
[*]Position Sizing: Inversely modulated based on normalized EVAR

The q-parameter controls tail sensitivity—higher values (1.5-2.0) increase the weighting of extreme events in the calculation, making the model more conservative during potentially turbulent conditions.

Indicator Components
1. EVAR Risk Visualization

[*]Dynamic EVAR Plot: Color-coded from red to green normalized risk measurement (0-1)
[*]Risk Thresholds: Reference lines at 0.3, 0.5, and 0.7 delineating risk zones

2. Position Sizing Matrix

[*]Risk Assessment: Current risk level and raw EVAR value
[*]Position Recommendations: Percentage allocation, dollar value, and quantity
[*]Stop Parameters: Mathematically derived stop price with percentage distance
[*]Drawdown Projection: Maximum theoretical loss if stop is triggered

Interpretation and Application
The normalized EVAR reading provides a probabilistic risk assessment:

[*]< 0.3: Low risk environment with minimal tail concerns
[*]0.3-0.5: Moderate risk with standard tail behavior
[*]0.5-0.7: Elevated risk with increased probability of significant moves
[*]> 0.7: High risk environment with substantial tail risk present

Position sizing is automatically calculated using an inverse relationship to EVAR, contracting during high-risk periods and expanding during low-risk conditions. This is a counter-cyclical approach that ensures consistent risk exposure across varying market regimes, especially when the market is hyped or overheated. 

Parameter Optimization
For optimal risk assessment across market conditions:

[*]Lookback Period: Determines the historical window for risk calculation
[*]Q Parameter: Controls tail sensitivity (higher values increase conservatism)
[*]Confidence Level: Sets the statistical threshold for risk assessment

For cryptocurrencies and highly volatile instruments, a q-parameter between 1.5-2.0 typically provides the most accurate risk assessment because it helps capturing the fat-tailed behavior characteristic of these markets. You can also increase the q-parameter for more conservative approaches. 

Practical Applications

[*]Adaptive Risk Management: Quantify and respond to changing tail risk conditions
[*]Volatility-Normalized Positioning: Maintain consistent exposure across market regimes
[*]Black Swan Detection: Early identification of potential extreme market conditions
[*]Portfolio Construction: Apply consistent risk-based sizing across diverse instruments

This indicator is my own approach to entropy-based risk measures as an alterative to volatility and standard deviations and it helps with fat-tailed markets.

Enjoy!

---

## Source Code

````pine
//@version=6
//By henrique Centieiro
//Update log:
//18/07/2025: Fixed EVaR Value display in the information table to show meaningful percentages. Line 105: Changed table display from str.tostring(evar_value, "#.####") to str.tostring(normalized_evar * 100, "#.##") + "%"
indicator("EVaR Indicator and Position Sizing", overlay=false, max_labels_count=1)

// ===== INPUT PARAMETERS =====
var g_params = "EVAR Parameters"
lookback = input.int(100, "Lookback Period", minval=10, maxval=500, group=g_params)
alpha = input.float(0.05, "Confidence Level (α)", minval=0.01, maxval=0.99, group=g_params)
q_param = input.float(1.5, "Q Parameter (Tsallis)", minval=1.1, maxval=2.5, group=g_params)

var g_position = "Position Sizing"
max_position = input.float(100, "Maximum Position Size (%)", minval=1, maxval=100, group=g_position)
account_size = input.float(10000, "Account Size ($)", minval=100, group=g_position)
risk_percent = input.float(2, "Risk Per Trade (%)", minval=0.1, maxval=10, group=g_position)

var g_visual = "Visualization"
show_tables = input.bool(true, "Show Position Info Table", group=g_visual)
color_bars = input.bool(false, "Color Price Bars by Risk", group=g_visual)

// ===== EVAR CALCULATION =====
// Calculate returns
returns = ta.change(close) / close[1]

// Function to calculate simplified Entropic Value at Risk
simplified_evar() =>
    // Calculate moment generating function approximation
    sum_mgf = 0.0
    for i = 0 to lookback-1
        // Using q-exponential from Tsallis statistics for non-Gaussian distributions
        q_exp = math.pow(1 + (q_param - 1) * returns[i], 1 / (q_param - 1))
        sum_mgf := sum_mgf + q_exp
    
    mgf_value = sum_mgf / lookback
    
    // Calculate EVAR (simplified version)
    evar = math.log(mgf_value / alpha) / (2 - q_param)
    
    // Ensure we return a positive value
    math.abs(evar)

// Get EVAR value
evar_value = simplified_evar()

// Calculate volatility for comparison
volatility = ta.stdev(returns, lookback)

// Calculate EVAR to volatility ratio
evar_vol_ratio = evar_value / volatility

// Normalize the EVAR for better visualization (between 0 and 1)
max_evar = ta.highest(evar_value, 250)
min_evar = ta.lowest(evar_value, 250)
evar_range = max_evar - min_evar
normalized_evar = evar_range > 0 ? (evar_value - min_evar) / evar_range : 0.5

// ===== POSITION SIZING CALCULATION =====
// Calculate position size adjustment factor (As EVAR increases, position size decreases)
position_adjustment = math.max(0.1, 1 - normalized_evar)

// Calculate recommended position size
recommended_position_size = max_position * position_adjustment

// Calculate dollar position size
dollar_position = (account_size * recommended_position_size / 100)

// Calculate position in shares
shares_to_buy = math.floor(dollar_position / close)

// Calculate risk-based stop loss distance
risk_amount = account_size * (risk_percent / 100)
max_stop_distance_percent = (risk_amount / dollar_position) * 100
stop_price = close * (1 - max_stop_distance_percent / 100)

// Calculate theoretical max drawdown (worst case scenario)
theoretical_max_drawdown = (risk_percent / 100) * recommended_position_size / max_position

// ===== VISUALIZATION =====
// Define risk levels for color coding with more vibrant colors
risk_level = normalized_evar > 0.7 ? "High" : normalized_evar > 0.5 ? "Medium" : "Low"
risk_color = normalized_evar > 0.7 ? #FF1744 : normalized_evar > 0.5 ? #FF9100 : #00C853  // Vibrant red, orange, green

// Color candles by risk if enabled
barcolor(color_bars ? risk_color : na)

// ===== PLOTTING PANELS =====
// Panel 1: EVAR Risk Level with more vibrant colors
plot(normalized_evar, "Normalized EVAR", risk_color, 3)  // Increased line width
hline(0.5, "Medium Risk", #757575, hline.style_dashed)  // Darker gray
hline(0.7, "High Risk", #FF1744, hline.style_dashed)    // Vibrant red
hline(0.3, "Low Risk", #00C853, hline.style_dashed)     // Vibrant green
bgcolor(color.new(risk_color, 85))  // Reduced transparency for sharper background

// ===== INFORMATION TABLES =====
if barstate.islast and show_tables
    // Create position sizing information table with sharper colors
    var table position_table = table.new(position=position.top_right, columns=2, rows=8, bgcolor=color.new(#212121, 10), border_width=1, border_color=#EEEEEE)
    
    // Clear previous data
    table.clear(position_table, 0, 0, 1, 7)
    
    // Table headers - more vibrant blue
    table.cell(position_table, 0, 0, "EVAR Position Sizing", text_color=#FFFFFF, bgcolor=color.new(#2962FF, 10), text_size=size.normal)
    table.cell(position_table, 1, 0, "", text_color=#FFFFFF, bgcolor=color.new(#2962FF, 10), text_size=size.normal)
    
    // Risk metrics
    table.cell(position_table, 0, 1, "Risk Level", text_color=#EEEEEE)
    table.cell(position_table, 1, 1, risk_level, text_color=risk_color, text_size=size.normal)
    
    table.cell(position_table, 0, 2, "EVAR Value", text_color=#EEEEEE)
    table.cell(position_table, 1, 2, str.tostring(normalized_evar * 100, "#.##") + "%", text_color=#FFFFFF)
    
    // Position sizing - with more vibrant colors
    table.cell(position_table, 0, 3, "Position Size", text_color=#EEEEEE)
    table.cell(position_table, 1, 3, str.tostring(recommended_position_size, "#.##") + "%", text_color=#64B5F6)
    
    table.cell(position_table, 0, 4, "Trade Amount", text_color=#EEEEEE)
    table.cell(position_table, 1, 4, "$" + str.tostring(dollar_position, "#,##0.00"), text_color=#64B5F6)
    
    table.cell(position_table, 0, 5, "Shares/Units", text_color=#EEEEEE)
    table.cell(position_table, 1, 5, str.tostring(shares_to_buy, "#,##0"), text_color=#64B5F6)
    
    // Stop loss - vibrant orange
    table.cell(position_table, 0, 6, "Stop Price", text_color=#EEEEEE)
    table.cell(position_table, 1, 6, "$" + str.tostring(stop_price, "#,##0.00") + " (" + str.tostring(max_stop_distance_percent, "#.##") + "%)", text_color=#FFAB40)
    
    // Max drawdown - vibrant red
    table.cell(position_table, 0, 7, "Max Drawdown", text_color=#EEEEEE)
    table.cell(position_table, 1, 7, str.tostring(theoretical_max_drawdown * 100, "#.##") + "%", text_color=#FF5252)
````
