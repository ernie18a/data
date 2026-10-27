# Options Greeks Dashboard

- url: https://www.tradingview.com/script/D38ZP8Fe-Options-Greeks-Dashboard/
- type: indicator
- pine_id: PUB;c13aa9933f194e38aa7983673267b124
- version: 1.0

## Description

Option Greeks Dashboard used to track option data for selling and buying

## Source Code

````pine
//@version=6
indicator("Options Greeks Dashboard", overlay=true)

// --- Inputs ---
daysToExpiry = input.int(30, "Days to Expiration (DTE)", minval=1)
riskFreeRate = input.float(4.5, "Risk-Free Rate (%)") / 100
strikePrice  = input.float(0.0, "Target Strike (0 = ATM)", minval=0.0)

// --- IV Estimation (ATM Approximation) ---
// Standard deviation of returns is a common proxy for IV.
// We use a 20-period historical volatility (HV) as an estimation for IV.
hvLen = 20
logReturns = math.log(close / close[1])
stdevReturns = ta.stdev(logReturns, hvLen)
annualizedIV = stdevReturns * math.sqrt(252) // Annualized HV as IV proxy

// --- Greeks Approximation Logic ---
// Note: These are mathematical approximations for dashboarding purposes, 
// not a full Black-Scholes model which requires complex cumulative distribution functions.

float S = close
float K = strikePrice == 0.0 ? close : strikePrice
float T = daysToExpiry / 365.0
float sigma = annualizedIV
float r = riskFreeRate

// 1. Delta Approximation (d1 approximation)
// Delta for ATM is roughly 0.5. We use a linear approximation for moneyness.
float d1 = (math.log(S / K) + (r + math.pow(sigma, 2) / 2) * T) / (sigma * math.sqrt(T))
float approxDelta = 0.5 + (0.4 * d1) // Scaled approximation
approxDelta := math.max(0.0, math.min(1.0, approxDelta))

// 2. Gamma Approximation
// Gamma is highest ATM and decreases as we move away.
float gamma = math.exp(-math.pow(d1, 2) / 2) / (S * sigma * math.sqrt(2 * math.pi * T))

// 3. Theta Approximation (Daily Decay)
// Simplified Theta: focuses on the passage of time impact on extrinsic value.
float theta = -(S * sigma * math.exp(-math.pow(d1, 2) / 2)) / (2 * math.sqrt(2 * math.pi * T)) / 365.0

// 4. Vega Approximation
// Vega is the sensitivity to 1% change in IV.
float vega = S * math.sqrt(T) * (math.exp(-math.pow(d1, 2) / 2) / math.sqrt(2 * math.pi)) / 100.0

// --- Dashboard Table ---
var table greeksTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    // Header
    table.cell(greeksTable, 0, 0, "Greek", text_color=color.white, text_size=size.small)
    table.cell(greeksTable, 1, 0, "Value", text_color=color.white, text_size=size.small)
    
    // IV Row
    table.cell(greeksTable, 0, 1, "Est. IV (Ann.)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(greeksTable, 1, 1, str.format("{0,number,#.##%}", annualizedIV), text_color=color.yellow, text_size=size.small)
    
    // Delta Row
    table.cell(greeksTable, 0, 2, "Approx. Delta", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(greeksTable, 1, 2, str.format("{0,number,#.###}", approxDelta), text_color=color.aqua, text_size=size.small)
    
    // Gamma Row
    table.cell(greeksTable, 0, 3, "Approx. Gamma", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(greeksTable, 1, 3, str.format("{0,number,#.####}", gamma), text_color=color.orange, text_size=size.small)
    
    // Theta Row
    table.cell(greeksTable, 0, 4, "Daily Theta", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(greeksTable, 1, 4, str.format("{0,number,#.###}", theta), text_color=color.red, text_size=size.small)
    
    // Vega Row
    table.cell(greeksTable, 0, 5, "Vega (1% IV)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(greeksTable, 1, 5, str.format("{0,number,#.###}", vega), text_color=color.green, text_size=size.small)

// Visual Plot for Theta Decay Trend (Optional separate pane or data window)
plot(theta, "Theta Value", color=color.red, display=display.data_window)
plot(annualizedIV, "Estimated IV", color=color.yellow, display=display.data_window)
````
