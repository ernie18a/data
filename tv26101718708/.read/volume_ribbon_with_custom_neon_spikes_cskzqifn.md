# Volume Ribbon with Custom Neon Spikes

- url: https://www.tradingview.com/script/CSkzqiFN-Volume-Ribbon-with-Custom-Neon-Spikes/
- type: indicator
- pine_id: PUB;a1d4ac5424734a34be4821fe371e4a81
- version: 1.0

## Description

The [b]Volume Ribbon with Custom Neon Spikes[/b] is a momentum-driven indicator that isolates underlying market sentiment by plotting the net difference between buying and selling volume as a dynamic central histogram. 
Moving average crossovers and directional shifts dictate standard green and red gradient tones, while a smoothed orange signal line provides early warnings for shifting trends. To ensure you never miss institutional activity, the script features a built-in alert system that instantly overrides standard colors with brilliant, custom neon green or neon pink highlights whenever a massive volume spike occurs—specifically defined as a bar printing at over 2x the recent total volume average.

## Source Code

````pine
//@version=6
indicator("Volume Ribbon with Custom Neon Spikes - v6", shorttitle="Vol Ribbon Custom v6", overlay=false)

// ==============================
// === USER SETTINGS (INPUTS) ===
// ==============================
int maLength     = input.int(20, title="Volume MA Length", minval=1, tooltip="Adjusts the lookback period for the underlying Buy and Sell MAs")
string maType    = input.string("SMA", title="Volume MA Type", options=["SMA", "EMA"])
int signalLength = input.int(9, title="Signal Line Length", minval=1, tooltip="Smoothes out the Ribbon to show an early momentum trigger line")

// === Calculate buying and selling volume based on price action ===
float upward_range = math.max(close - low, 0)
float downward_range = math.max(high - close, 0)

float total_range = high - low
total_range := total_range == 0 ? 1 : total_range

float buy_proportion = upward_range / total_range
float sell_proportion = downward_range / total_range

float total_proportion = buy_proportion + sell_proportion
buy_proportion := total_proportion > 0 ? buy_proportion / total_proportion : 0
sell_proportion := total_proportion > 0 ? sell_proportion / total_proportion : 0

float buy_volume = volume * buy_proportion
float sell_volume = volume * sell_proportion

// === Calculate Underlying Moving Averages ===
float buy_ma  = maType == "SMA" ? ta.sma(buy_volume, maLength) : ta.ema(buy_volume, maLength)
float sell_ma = maType == "SMA" ? ta.sma(sell_volume, maLength) : ta.ema(sell_volume, maLength)

// Total volume moving average used to calculate the 2x volume spike condition
float total_vol_ma = ta.sma(volume, maLength)

// ============================================
// ===      RIBBON & SPIKE COLOR LOGIC      ===
// ============================================
// Calculate the raw net difference between the two volume MAs
float ribbon = buy_ma - sell_ma

// Calculate a smoothed signal line of that ribbon for early cross triggers
float signal = ta.ema(ribbon, signalLength)

// Condition: Is the current volume bar at least twice as high as the total moving average?
bool is_volume_spike = volume >= (total_vol_ma * 2.0)

// Condition: Are buyers or sellers dominant within the current bar?
bool buyers_dominant = buy_volume > sell_volume

// Define Custom Neon Colors based on RGB coordinates
color customNeonGreen = color.rgb(182, 255, 0, 0)
color customNeonRed   = color.rgb(255, 131, 196, 0)

// Determine colors based on direction, crossovers, and special volume spike rules
color ribbonColor = color.gray

if is_volume_spike
    // Trigger your precise custom neon highlights during a 2x volume surge
    ribbonColor := buyers_dominant ? customNeonGreen : customNeonRed
else
    // Standard color rules for normal volume environments
    if ribbon >= 0
        ribbonColor := ribbon > ribbon[1] ? color.new(color.green, 20) : color.new(color.green, 50)
    else
        ribbonColor := ribbon < ribbon[1] ? color.new(color.red, 20) : color.new(color.red, 50)

// === Plots ===
// 1. Zero Line reference
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// 2. The Main Sentiment Ribbon (Histogram)
plot(ribbon, title="Volume Ribbon", color=ribbonColor, style=plot.style_histogram, linewidth=4)

// 3. The Early Warning Signal Line
plot(signal, title="Ribbon Signal Line", color=color.new(color.orange, 0), linewidth=2)
````
