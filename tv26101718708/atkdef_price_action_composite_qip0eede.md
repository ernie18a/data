# ATK/DEF Price Action Composite 

- url: https://www.tradingview.com/script/qIp0EEdE/
- type: indicator
- pine_id: PUB;f9c41d5b6dc24a3ea21a8acc16d943a9
- version: 1.0

## Description

PAC — Price Action Composite Indicator 

Description

PAC (Price Action Composite) is a multi-factor price action analysis tool designed to visualize and organize market behavior through a combination of candle structure, trend conditions, and volume-based money flow analysis.

Unlike traditional single-factor indicators, PAC combines several independent market observations into one composite framework to help analyze how price is behaving under different market conditions.

The indicator focuses on the relationship between candle anatomy, directional strength, trend alignment, and participation intensity.

Core Concepts
1. Candle Structure Analysis

PAC analyzes the internal structure of each candle by measuring:

Body Strength

Body Strength represents the relationship between candle body size and the total candle range.

It helps visualize directional candle pressure:

Positive values indicate stronger upward candle structure.
Negative values indicate stronger downward candle structure.
Values near zero represent weaker directional commitment.

Upper Wick Ratio

Measures the proportion of the upper wick compared with the complete candle range.

This helps identify areas where price attempted higher levels but experienced rejection.

Higher values indicate stronger upper rejection characteristics.

Lower Wick Ratio

Measures the proportion of the lower wick compared with the complete candle range.

This highlights areas where lower prices were tested and rejected.

Higher values indicate stronger lower rejection characteristics.

2. Trend Environment

PAC uses two moving averages to classify the current market environment:

20-period moving average
60-period moving average

The trend module evaluates price position and moving average alignment to categorize market conditions:

Uptrend

Price is positioned above both moving averages with bullish alignment.

Downtrend

Price is positioned below both moving averages with bearish alignment.

Bounce

Price is recovering above the short-term average while the longer-term structure remains weaker.

Pullback

Price is below the short-term average while the longer-term structure remains stronger.

Neutral

Market structure does not show clear directional alignment.

3. Money Flow Analysis

PAC incorporates Chaikin Money Flow (CMF) to measure the relationship between:

Closing location within the candle range
volume
Accumulation and distribution pressure

The money flow component helps visualize participation characteristics:

Strong Inflow

Higher positive money flow pressure.

Mild Inflow

Moderate positive participation.

Neutral

Balanced market participation.

Mild Outflow

Moderate negative pressure.

Strong Outflow

Higher negative money flow pressure.

4. Candle Classification

Each candle is categorized according to:

Body-to-range proportion
Directional strength
Candle expansion characteristics

The classification includes:

Doji

Small candle body indicating limited directional commitment.

Strong Bull

Large positive candle body showing stronger upward candle structure.

Strong Bear

Large negative candle body showing stronger downward candle structure.

Mild Bull

Positive candle structure with moderate strength.

Mild Bear

Negative candle structure with moderate weakness.

Information Panel

PAC includes a compact monitoring panel displaying:

Current trend environment
Upper wick ratio
Lower wick ratio
Candle body strength
Money flow condition
Candle classification
Overall market monitoring status

The panel is designed to provide a quick overview of current price behavior without relying on a single measurement.

Calculation Approach

PAC does not attempt to forecast future price movement.

Instead, it combines multiple market observations into a structured visualization system:

Candle Behavior + Trend Structure + Volume Participation = Composite Market Condition

The purpose is to help users interpret current market characteristics and compare different price action environments.

Intended Use

PAC is designed for traders who study:

Candlestick behavior
Market structure
Trend conditions
Volume participation
Price reaction characteristics

It can be used as a supporting analytical tool alongside a own methodology process.

Notes

PAC is an analytical visualization tool.

It does not generate guaranteed outcomes and does not provide or autom decisions.

## Source Code

````pine
//@version=6
indicator(" PAC  ", overlay=false, precision=2)

// ========================================
// 1. Raw Candle Data
// ========================================
body = math.abs(close - open)
candleRange = high - low

upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

upperWickRatio = candleRange > 0 ? upperWick / candleRange : 0
lowerWickRatio = candleRange > 0 ? lowerWick / candleRange : 0
bodyStrength = candleRange > 0 ? (close - open) / candleRange : 0

// ========================================
// 2. Trend Determination
// ========================================
ma20 = ta.sma(close, 20)
ma60 = ta.sma(close, 60)

trendLabel = "⚪ Neutral"
trendColor = color.gray

if close > ma20 and ma20 > ma60
    trendLabel := "🟢 Uptrend"
    trendColor := color.green
else if close < ma20 and ma20 < ma60
    trendLabel := "🔴 Downtrend"
    trendColor := color.red
else if close > ma20 and ma20 < ma60
    trendLabel := "🟡 Bounce"
    trendColor := color.orange
else if close < ma20 and ma20 > ma60
    trendLabel := "🟡 Pullback"
    trendColor := color.orange

// ========================================
// 3. Fund Flow —— Chaikin Money Flow
// ========================================
moneyFlowMultiplier = candleRange > 0 ? ((close - low) - (high - close)) / candleRange : 0
moneyFlowVolume = moneyFlowMultiplier * volume
cmf = math.sum(moneyFlowVolume, 20) / math.sum(volume, 20)

fundFlowLabel = "⚖️ Neutral"
fundFlowColor = color.gray

if cmf > 0.15
    fundFlowLabel := "🟢 Strong Inflow"
    fundFlowColor := color.green
else if cmf > 0.05
    fundFlowLabel := "🟢 Mild Inflow"
    fundFlowColor := color.lime
else if cmf < -0.15
    fundFlowLabel := "🔴 Strong Outflow"
    fundFlowColor := color.red
else if cmf < -0.05
    fundFlowLabel := "🔴 Mild Outflow"
    fundFlowColor := color.maroon

// ========================================
// 4. Plot Indicators
// ========================================
hline(0.7, "Heavy Sell Pressure", color=color.new(color.white, 50), linestyle=hline.style_dashed)
plot(upperWickRatio, title="Upper Wick Ratio", color=color.new(color.green, 0), linewidth=2, style=plot.style_area)

hline(0, "Zero Line", color=color.white, linestyle=hline.style_dotted)
plot(bodyStrength, title="Body Strength", color=color.new(color.blue, 0), linewidth=2, style=plot.style_histogram)

plot(cmf, title="Chaikin Money Flow (CMF)", color=color.rgb(237, 249, 8), linewidth=2)

// ========================================
// 5. Candle Type Classification
// ========================================
candleType = ""
candleTypeColor = color.gray
bodyPct = candleRange > 0 ? body / candleRange : 0

if bodyPct < 0.15
    candleType := "✧ Doji"
    candleTypeColor := color.yellow
else if bodyStrength > 0.6
    candleType := "☀️ Strong Bull"
    candleTypeColor := color.green
else if bodyStrength < -0.6
    candleType := "🌧️ Strong Bear"
    candleTypeColor := color.red
else if bodyStrength > 0
    candleType := "🌤️ Mild Bull"
    candleTypeColor := color.lime
else
    candleType := "🌨️ Mild Bear"
    candleTypeColor := color.maroon

// ========================================
// 6. Info Panel (2-Column · Industrial Aesthetic)
// ========================================
var table info = table.new(
     position.bottom_right, 
     2, 8, 
     bgcolor=color.new(color.rgb(10, 14, 20), 92), 
     border_width=1, 
     border_color=color.rgb(60, 100, 140, 60)
)

if barstate.islast
    // Header
    table.cell(info, 0, 0, "◆ SYS.MONITOR", 
         text_color=color.rgb(0, 220, 255), 
         bgcolor=color.rgb(30, 50, 70, 60), 
         text_size=size.small, 
         text_halign=text.align_right)
    table.cell(info, 1, 0, "", 
         bgcolor=color.rgb(30, 50, 70, 60), 
         text_size=size.small)
    
    // Data Rows
    table.cell(info, 0, 1, "TREND", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 1, trendLabel, 
         text_color=trendColor, text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 2, "UPPER WICK", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 2, str.tostring(upperWickRatio, "#0.00"), 
         text_color=color.rgb(255, 80, 80), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 3, "LOWER WICK", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 3, str.tostring(lowerWickRatio, "#0.00"), 
         text_color=color.rgb(0, 230, 140), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 4, "BODY STRENGTH", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 4, str.tostring(bodyStrength, "#0.00"), 
         text_color=bodyStrength > 0 ? color.rgb(0, 200, 255) : color.rgb(255, 120, 120), 
         text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 5, "FUND FLOW", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 5, fundFlowLabel, 
         text_color=fundFlowColor, text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 6, "CANDLE TYPE", 
         text_color=color.rgb(140, 165, 185), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 6, candleType, 
         text_color=candleTypeColor, text_size=size.small, text_halign=text.align_right)
    
    // ========================================
    // Bottom Status Row (with Quick Memory Guide)
    // ========================================
    statusText = (trendLabel == "🟢 Uptrend" ? "● ACTIVE  ✅ GO" :
                  trendLabel == "🔴 Downtrend" ? "● ALERT   ⚠️ CAUTION" :
                  "● MONITOR 👀 WAIT")
    
    color fixedStatusColor = color.rgb(0, 220, 255)
    
    table.cell(info, 0, 7, statusText, 
         text_color=fixedStatusColor, 
         bgcolor=color.new(color.rgb(10, 14, 20), 0),
         text_size=size.small, 
         text_halign=text.align_center)
    table.cell(info, 1, 7, "", 
         bgcolor=color.new(color.rgb(10, 14, 20), 0), 
         text_size=size.small)
````
