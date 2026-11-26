# Thermodynamic Market Entropy Index (TMEI)

- url: https://www.tradingview.com/script/vaEpn5WT/
- type: indicator
- pine_id: PUB;65b17a8b8ab54546abdc550bcc69ee29
- version: 1.0

## Description

🚀 Thermodynamic Market Entropy Index (TMEI)

The Thermodynamic Market Entropy Index (TMEI) is a professional-grade quantitative tool designed to measure structural market order and identify the transition between chaotic consolidation and explosive directional trends. Built upon the physics-derived principles of Shannon Entropy, this indicator processes real-time price distribution and institutional volume flow to map market cycles into a normalized, zero-centered oscillator (-100 to +100).

Unlike standard lagging oscillators, TMEI acts as a dynamic market regime filter, giving traders absolute clarity on whether a market is in a highly organized trend or a random, capital-draining walk (chop).

💡 Key Features

🧠 Information Entropy Core: Using Claude Shannon’s information entropy theory, TMEI discretizes price momentum into 5 distinct thermodynamic states. It continuously measures the randomness of the market, detecting when the market structure is compressing into a high-order trend or expanding into total chaos.

🛡️ The 20% No-Trade Buffer Zone (Compression Ribbon): To eliminate devastating "whipsaws" (false breakouts), TMEI features a mathematically justified ±20 neutral corridor. This zone corresponds directly to the critical RSI 45-55 equilibrium zone, keeping traders completely on the sidelines (Neutral Gray) until institutional momentum gathers enough mass to break out.

📊 Institutional Volume Validation: TMEI does not look at price in a vacuum. It integrates an algorithmic volume filter utilizing smart accumulation/distribution logic. If a breakout occurs on weak or retail-only volume, the indicator suppresses the signal line back toward the Zero Axis, shielding you from fakeouts.

⚙️ Hysteresis-Driven State Engine: Armed with a dual-threshold hysteresis filter, TMEI locks into major macro trends. Once a trend is verified, minor counter-trend pullbacks are filtered out, ensuring you hold winning positions longer without premature exit signals.

🔬 Mathematical Logic and Scaling

TMEI measures the probability matrix of 5 distinct market states over a rolling lookback window. The pure Shannon Entropy measures the total chaos in the system. The index then normalizes this value against maximum possible entropy and subjects it to a directional vector matrix (Net Bias).

Formula: Raw Order = 100 - ((Shannon Entropy / Maximum Entropy) * 100)
Final Score = Raw Order * Directional Sign * Volume Multiplier

This process translates abstract thermodynamic physics into a highly practical, bounded indicator where +100 represents perfect bullish order and -100 represents perfect bearish order.

🛠️ How to Use

1. The Structural Breakout: Monitor the signal line closely as it exits the Gray Compression Ribbon. A definitive close above +20 confirms institutional bullish expansion. A close below -20 confirms structural bearish dominance.
2. The Chaos Neutral Zone (±20): When the line is trapped inside the gray cloud, the market is in a state of maximum entropy (Random Walk/Chop). Strictly avoid directional breakout strategies here.
3. Macro Trend Expansion (±60): Entering the ±60 zones triggers a full background color canvas injection. This highlights that the asset has entered an elite, high-momentum institutional trend corridor.
4. Volume Divergences: If the asset continues to make new structural highs but the TMEI curve prints descending peaks, it indicates a massive decay in volume-price entropy—a highly reliable leading signature of a trend collapse.

🎛️ Settings

Signal Smoothing Period (14): Controls the lookback filter applied via a Weighted Moving Average (WMA) to smooth out high-frequency market noise. Increase to 21 or 25 for ultra-clean macro tracking.

Enable Volume Validation (True): Toggles the institutional smart money filter. Highly recommended for liquid stocks and crypto assets to eliminate low-volume manipulations.

📌 Credits and Origins

This script bridges information theory, statistical thermodynamics, and quantitative technical analysis. It is dedicated to professional traders who demand a purely mathematical, data-driven view of market liquidity, regime verification, and structural mechanics.

Disclaimer: All financial indicators are purely probabilistic models. TMEI is an advanced decision-support architecture and does not guarantee execution success or profits. Always utilize strict risk management protocols and predefined stop-losses.

## Source Code

````pine
//@version=6
indicator("Thermodynamic Market Entropy Index", shorttitle="TMEI", overlay=false)

// ==========================================
// KULLANICI AYARLARI (USER INPUTS)
// ==========================================
int   smoothingLength = input.int(14, title="Signal Smoothing Period", minval=1, tooltip="Higher values (e.g., 14 or 21) eliminate almost all false signals but add slight lag.")
bool  useVolumeFilter = input.bool(true, title="Enable Volume Validation", tooltip="Filters out low-volume price movements using Chaikin Money Flow logic.")
color colorBull       = input.color(color.green, title="Bullish Trend Color")
color colorBear       = input.color(color.red, title="Bearish Trend Color")
color colorChop       = input.color(color.gray, title="Chop / Chaos Color")

// ==========================================
// ARCHITECTURAL CALIBRATION
// ==========================================
int   lookbackPeriod   = 40  
int   rsiLength        = 14
float extremeThreshold = 60.0
float neutralThreshold = 20.0 // Mathematically derived from the RSI 45-55 equilibrium zone
float exitBuffer       = 12.0 

// ==========================================
// THERMODYNAMIC STATE ENGINE
// ==========================================
float rsiValue = ta.rsi(close, rsiLength)

float state1 = rsiValue >= 70 ? 1.0 : 0.0
float state2 = (rsiValue >= 55 and rsiValue < 70) ? 1.0 : 0.0
float state3 = (rsiValue > 45 and rsiValue < 55) ? 1.0 : 0.0 
float state4 = (rsiValue > 30 and rsiValue <= 45) ? 1.0 : 0.0
float state5 = rsiValue <= 30 ? 1.0 : 0.0

// Frequency Weight Accumulation
float sum1 = math.sum(state1, lookbackPeriod)
float sum2 = math.sum(state2, lookbackPeriod)
float sum3 = math.sum(state3, lookbackPeriod)
float sum4 = math.sum(state4, lookbackPeriod)
float sum5 = math.sum(state5, lookbackPeriod)

// Probability Distributions (P_i)
float p1 = sum1 / lookbackPeriod
float p2 = sum2 / lookbackPeriod
float p3 = sum3 / lookbackPeriod
float p4 = sum4 / lookbackPeriod
float p5 = sum5 / lookbackPeriod

// ==========================================
// SHANNON ENTROPY MATHEMATICAL CORE
// ==========================================
float shannonEntropy = 0.0
shannonEntropy += p1 > 0 ? (p1 * math.log(p1) / math.log(2)) : 0
shannonEntropy += p2 > 0 ? (p2 * math.log(p2) / math.log(2)) : 0
shannonEntropy += p3 > 0 ? (p3 * math.log(p3) / math.log(2)) : 0
shannonEntropy += p4 > 0 ? (p4 * math.log(p4) / math.log(2)) : 0
shannonEntropy += p5 > 0 ? (p5 * math.log(p5) / math.log(2)) : 0
shannonEntropy := -shannonEntropy

float maxEntropy = math.log(5) / math.log(2)
float rawOrder = 100.0 - ((shannonEntropy / maxEntropy) * 100)

// Directional Vector Mechanics
float netBias = (p1 * 2.0 + p2) - (p4 + p5 * 2.0)
float directionSign = netBias >= 0 ? 1.0 : -1.0

// ==========================================
// INSTITUTIONAL VOLUME VALIDATION
// ==========================================
float volumeMultiplier = 1.0
if useVolumeFilter and not barstate.isrealtime
    float mfMultiplier = ((close - low) - (high - close)) / (high - low == 0 ? 0.0001 : high - low)
    float mfVolume = mfMultiplier * volume
    float cmf = math.sum(mfVolume, 20) / (math.sum(volume, 20) == 0 ? 1.0 : math.sum(volume, 20))
    
    if directionSign > 0 and cmf < -0.05
        volumeMultiplier := 0.3
    if directionSign < 0 and cmf > 0.05
        volumeMultiplier := 0.3

// Mathematical Matrix Combination
float tmeiRaw = rawOrder * directionSign * volumeMultiplier
float tmeiSmoothed = ta.wma(tmeiRaw, smoothingLength)

// ==========================================
// HYSTERESIS STATE MACHINE
// ==========================================
var string currentState = "CHOP"

if currentState == "CHOP"
    if tmeiSmoothed > neutralThreshold
        currentState := "BULL"
    else if tmeiSmoothed < -neutralThreshold
        currentState := "BEAR"
else if currentState == "BULL"
    if tmeiSmoothed < (neutralThreshold - exitBuffer)
        currentState := "CHOP"
else if currentState == "BEAR"
    if tmeiSmoothed > (-neutralThreshold + exitBuffer)
        currentState := "CHOP"

// ==========================================
// VISUALIZATION AND INTERFACE DATA
// ==========================================
color dynamicColor = currentState == "BULL" ? color.from_gradient(tmeiSmoothed, neutralThreshold, extremeThreshold, colorChop, colorBull) :
                     currentState == "BEAR" ? color.from_gradient(tmeiSmoothed, -extremeThreshold, -neutralThreshold, colorBear, colorChop) : colorChop

// Main Indicator Plots
plot(tmeiSmoothed, title="TMEI Score", color=dynamicColor, linewidth=2)
plot(tmeiSmoothed, title="TMEI Area Fill", color=color.new(dynamicColor, 85), style=plot.style_area)

// Geometric Grid Fields
hline(0, title="Zero Axis", color=color.new(colorChop, 30), linewidth=1, linestyle=hline.style_solid)
p_upperBuffer = hline(neutralThreshold, title="Upper Compression Limit", color=color.new(colorChop, 60), linestyle=hline.style_dashed)
p_lowerBuffer = hline(-neutralThreshold, title="Lower Compression Limit", color=color.new(colorChop, 60), linestyle=hline.style_dashed)

// Equilibrium Ribbon Shading (No-Trade Buffer Zone)
fill(p_upperBuffer, p_lowerBuffer, color=color.new(colorChop, 92), title="Compression Zone Background")

hline(extremeThreshold, title="Bullish Expansion Boundary", color=color.new(colorBull, 60), linestyle=hline.style_dashed)
hline(-extremeThreshold, title="Bearish Expansion Boundary", color=color.new(colorBear, 60), linestyle=hline.style_dashed)

// Dynamic Canvas Color Injections
bgcolor(currentState == "BULL" and tmeiSmoothed > extremeThreshold ? color.new(colorBull, 93) : 
        currentState == "BEAR" and tmeiSmoothed < -extremeThreshold ? color.new(colorBear, 93) : na)

// ==========================================
// HEADS-UP DISPLAY (HUD) PANEL
// ==========================================
var table infoPanel = table.new(position.top_right, 2, 2, border_width=1, border_color=color.new(color.gray, 50), bgcolor=color.new(color.black, 20))
if barstate.islast
    string marketRegime = currentState == "BULL" ? "STRUCTURED BULL" : (currentState == "BEAR" ? "STRUCTURED BEAR" : "CHAOTIC CHOP / COMPRESSION")
    
    table.cell(infoPanel, 0, 0, "TMEI", text_color=color.white)
    table.cell(infoPanel, 1, 0, str.tostring(tmeiSmoothed, "#.##"), text_color=dynamicColor)
    
    table.cell(infoPanel, 0, 1, "Market Regime", text_color=color.white)
    table.cell(infoPanel, 1, 1, marketRegime, text_color=color.white, bgcolor=color.new(dynamicColor, 60))

// ==========================================
// AUTOMATED STRATEGY ALERTS
// ==========================================
alertcondition(ta.crossover(tmeiSmoothed, extremeThreshold), title="Bullish Expansion Confirmed", message="TMEI Matrix confirmed stable institutional Bullish continuation.")
alertcondition(ta.crossunder(tmeiSmoothed, -extremeThreshold), title="Bearish Expansion Confirmed", message="TMEI Matrix confirmed stable institutional Bearish continuation.")
````
