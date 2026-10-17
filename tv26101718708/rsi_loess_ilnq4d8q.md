# RSI LOESS

- url: https://www.tradingview.com/script/iLnq4d8Q-RSI-LOESS/
- type: indicator
- pine_id: PUB;736475812667446ea60514ccab3b18ac
- version: 4.0

## Description

RSI LOESS - Volatility-Normalized Momentum Indicator with Adaptive Smoothing

An advanced momentum oscillator that enhances traditional RSI by combining standard deviation normalization with LOESS (Locally Estimated Scatterplot Smoothing) weighted averaging to create a more responsive and reliable trend strength filter.

Core Methodology:

The indicator applies a three-step transformation to price data:

Standard Deviation Normalization: Calculates RSI and subtracts its standard deviation, creating a volatility-adjusted baseline that adapts to changing market conditions
LOESS Weighted Smoothing: Applies customizable edge and center weighting to reduce noise while preserving signal integrity and minimizing lag
Binary Scoring System: Generates directional signals (+1/-1) at the 49 threshold for systematic trade execution
Optimized Zone Structure:

The indicator naturally oscillates between 30-70, with four distinct zones calibrated for this range:

RED (< 40): OVERSOLD - Weak momentum, potential reversal or continuation of downtrend
BLUE (40-50): BEARISH - Below neutral, conditions favor caution or short positioning
GREEN (50-60): BULLISH - Above neutral, momentum is building with early trend potential
ORANGE (60-70): OVERBOUGHT - Strong momentum, the "sweet spot" for trend following but watch for overextension
Trading Applications:

Long Entries: Look for transitions from RED into BLUE/GREEN zones as momentum shifts positive

Short Entries: Watch for moves from GREEN/ORANGE back into BLUE/RED zones as momentum weakens

The compressed zone triggers (40, 50, 60) provide earlier signals than traditional RSI levels (30, 70), making this ideal for swing trading and trend-following strategies.

Customizable Parameters:

RSI Length: Control the base momentum calculation period
SD Length: Adjust volatility normalization sensitivity
LOESS Smoothing Length: Fine-tune noise reduction vs. responsiveness
Edge/Center Weights: Customize the smoothing curve to match your trading style
Visual Features:

Color-coded line that changes based on current zone
Background fills highlighting each momentum zone
Real-time data table showing asset, current value, directional score, and zone classification
Perfect for traders seeking a sophisticated momentum filter that adapts to volatility while providing clear, actionable signals for trend identification and entry timing.

## Source Code

````pine
//@version=6
indicator("RSI LOESS", overlay=false, precision=2)

// RSIL

// This indicator calculates a modified RSI using a custom weighted moving average approach.
// 1. WMA Loss: Applies edge-weighted smoothing where values near center and edges get higher weights.
// 2. RSI Calculation: Uses the WMA-smoothed data with standard deviation-based normalization.
// 3. Score: Converts RSI to binary signal (1 or -1) at threshold 49 for directional bias.
// Use as a trend strength filter. Look for color transitions to identify momentum shifts.
// Take entries when moving from BLUE to GREEN zones for long, or GREEN to blue for short.

// --- INPUTS ---
RSI_len      = input.int(45, "LENGTH", group = "𝗥𝗦𝗜", tooltip = "Period for RSI calculation. Higher values create smoother, slower-moving RSI.")
RSI_sdlen    = input.int(90, "SD LENGTH", group = "𝗥𝗦𝗜", tooltip = "Lookback period for standard deviation calculation used in normalization. Higher values smooth out volatility adjustments.")
lengthLOESS  = input.int(5, title="LOESS Smoothing Length", group = "𝗥𝗦𝗜",tooltip = "Number of bars used for weighted moving average smoothing. Higher values increase smoothing but add lag.")
edgeWeight   = input.float(1.0, title="Edge Weight (Old/New)", group = "𝗥𝗦𝗜", minval=0.0, maxval=10.0, step=0.1, tooltip = "Weight applied to the oldest and newest values in the LOESS calculation. Higher values emphasize recent and older data points.")
centerWeight = input.float(0.0, title="Center Weight", group = "𝗥𝗦𝗜", minval=0.0, maxval=10.0, step=0.1, tooltip = "Weight applied to middle values in the LOESS calculation. Higher values emphasize the center of the smoothing window.")

// --- Helper Smoothing Function ---
wma_loess(src, length, edgeW, centerW) =>
    float sumWMA = 0.0
    float normFactor = 0.0
    for i = 0 to length - 1
        float position = length > 1 ? i / (length - 1.0) : 0.5
        float weight = 0.0 
        if position < 0.5
            weight := edgeW + (centerW - edgeW) * (position * 2)
        else
            weight := centerW + (edgeW - centerW) * ((position - 0.5) * 2)
        sumWMA += src[i] * weight
        normFactor += weight
    sumWMA / normFactor

// --- Function 1: The Value ---
RSIL() =>
    float RSI_rsi = ta.rsi(close, RSI_len)
    float RSI_atr = ta.stdev(RSI_rsi, RSI_sdlen)
    float RSI_dn  = RSI_rsi - RSI_atr
    wma_loess(RSI_dn, lengthLOESS, edgeWeight, centerWeight)

// --- Function 2: The Score ---
RSIL_score(value) =>
    bool RSI_long = value >= 49 
    int score = RSI_long ? 1 : -1
    score

// --- Function 3: The Color (Compressed Zones) ---
// Since the indicator stays mostly between 30 and 70, 
// we tighten the triggers to 40, 50, and 60.
get_zone_color(float val) =>
    color res = val < 40 ? color.red  : val < 50 ? color.blue   : val < 60 ? color.green : val < 70 ? color.orange : color.red
    res

// --- EXECUTION ---

// 1. Get the value
float rsi_dn_l_val = RSIL()

// 2. Get the score
int score_1 = RSIL_score(rsi_dn_l_val)

// 3. Get the color via function
color current_color = get_zone_color(rsi_dn_l_val)

// --- PLOT BACKGROUND ZONES ---
color c_green  = color.green
color c_blue   = color.blue
color c_orange = color.orange
color c_red    = color.red

p80 = plot(80, display=display.none)
p60  = plot(60,  "Level 60", color=color.new(color.white, 50))
p50  = plot(50,  "Level 50", color=color.new(color.white, 20), linewidth=1)
p40  = plot(40,  "Level 40", color=color.new(color.white, 50))
p20  = plot(20,   display=display.none)

fill(p60, p80, color.new(c_orange, 85),    title="Zone 60-80")
fill(p50, p60, color.new(c_green, 85), title="Zone 50-60")
fill(p40, p50, color.new(c_blue, 85),   title="Zone 40-50")
fill(p20, p40, color.new(c_red, 85),  title="Zone 20-40")

// --- PLOT MAIN LINE ---
plot(rsi_dn_l_val, "RSI LOESS Value", color=current_color, linewidth=2)

// --- DATA TABLE ---
var main_table = table.new(position.top_right, 4, 2, border_width=1, border_color=color.new(color.white, 50))

if barstate.islast
    string zone_name = rsi_dn_l_val < 40 ? "OVERSOLD" : 
                       rsi_dn_l_val < 50 ? "BEARISH" : 
                       rsi_dn_l_val < 60 ? "BULLISH" : "OVERBOUGHT"

    table.cell(main_table, 0, 0, "Asset",  bgcolor=color.black, text_color=color.white)
    table.cell(main_table, 1, 0, "Value",  bgcolor=color.black, text_color=color.white)
    table.cell(main_table, 2, 0, "Score",  bgcolor=color.black, text_color=color.white)
    table.cell(main_table, 3, 0, "Zone",   bgcolor=color.black, text_color=color.white)
    
    table.cell(main_table, 0, 1, syminfo.ticker, bgcolor=color.new(color.black, 20), text_color=color.white)
    table.cell(main_table, 1, 1, str.tostring(rsi_dn_l_val, "#.##"), bgcolor=color.new(color.black, 20), text_color=current_color)
    table.cell(main_table, 2, 1, str.tostring(score_1), bgcolor=color.new(color.black, 20), text_color=current_color)
    table.cell(main_table, 3, 1, zone_name, bgcolor=color.new(color.black, 20), text_color=current_color)
````
