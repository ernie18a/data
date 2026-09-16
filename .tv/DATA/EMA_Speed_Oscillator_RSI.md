<!-- tradingview-pine-id: PUB;9be1de03485e4efb92f9f4d90bae143d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Speed Oscillator + RSI

Source: https://www.tradingview.com/script/q6XWModj/

## Description

Title: EMA Speed Oscillator + RSI [Smart Momentum Filter]

Description:

The Core Philosophy: Fixing RSI's Biggest Flaw
The Relative Strength Index (RSI) is arguably one of the most popular oscillators in technical analysis. However, it has a massive functional blind spot: During strong, aggressive trends, the RSI can remain in "overbought" or "oversold" territories for extended periods.

Many traders get trapped trying to catch a falling knife just because the RSI is below 30, or they prematurely short a massive bull rally because the RSI is above 70.

The Solution: You need a true momentum filter to confirm the RSI. That is exactly what this indicator does. By merging the standard RSI with the velocity (Speed) of an Exponential Moving Average (EMA) in a single pane, this tool filters out the "noise" and fakeouts of the RSI. You no longer have to guess if an oversold RSI is a true reversal or just a trap in a strong downtrend.

How It Works Under the Hood
This indicator calculates the percentage rate of change (velocity) of a chosen EMA over a specific lookback period.
Instead of plotting the RSI on a separate 0-100 scale (which would create a visual mess when mixed with momentum percentages), the RSI is custom-scaled to flawlessly match the EMA Speed's visual range. This allows you to monitor exactly how price momentum and relative strength are interacting at any given second.

How to Trade Using This Indicator
Instead of printing rigid, lagging "Buy/Sell" labels, this indicator provides pure, readable momentum context so you can make informed decisions.

🟢 Bullish Reversal Setup (Long)
The Setup: Wait for the Scaled RSI (Orange line) to drop into or below the Oversold zone (Green dotted line).

The Trap Avoidance: Do NOT buy immediately. The downtrend might still be strong.

The Trigger: Wait for the EMA Speed (Colored line) to turn Green and aggressively cross ABOVE the Zero Line. This confirms that the true momentum has shifted bullish, validating the RSI reversal.

🔴 Bearish Reversal Setup (Short)
The Setup: Wait for the Scaled RSI (Orange line) to push into or above the Overbought zone (Red dotted line).

The Trap Avoidance: Do NOT short immediately. The bull trend might just be resting.

The Trigger: Wait for the EMA Speed to turn Red and aggressively cross BELOW the Zero Line. This confirms the sellers have taken control of the momentum.

Key Features Breakdown
EMA Speed Oscillator: Measures the true acceleration of the trend. Green line indicates positive momentum, Red line indicates negative momentum.

Perfectly Scaled RSI: The orange RSI line dynamically adapts to the EMA speed scale, preventing visual clutter while allowing precise crossover comparisons.

The Squeeze Zone (Purple Background): When the EMA Speed falls extremely close to the zero line, momentum is dead. The indicator paints the background Purple to warn you of a flat, choppy, or consolidating market. Rule of thumb: Avoid taking reversal trades inside the Purple Zone. Wait for a volatility breakout.

Live Status Dashboard: A sleek table in the top-right corner displays real-time EMA Speed %, standard RSI values, and current trend status (Rising, Falling, or Flat) at a single glance.

Default & Recommended Settings
The script is optimized by default for high-sensitivity, short-to-medium term momentum tracking:

EMA Period: 6

Lookback Period: 13 (Measures how much the EMA has moved compared to 13 bars ago)

Note: You can freely adjust these in the settings to suit higher timeframes (like 1D or 1W) for swing trading.

Disclaimer: This script is for educational and analytical purposes only. No indicator guarantees 100% accuracy. Always use this tool in conjunction with overall market structure, price action, and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("EMA Speed Oscillator + RSI", shorttitle="EMA_Speed_RSI", overlay=false, precision=4)

// ============ 1. PARAMETERS ============
// Default optimized settings: EMA = 6, Lookback = 13
length = input.int(6, title="EMA Period", minval=1)
offset = input.int(13, title="Lookback Period", minval=1, tooltip="How many bars back to measure the EMA speed")

// RSI Parameters
rsi_length = input.int(14, title="RSI Period", minval=1)
rsi_upper = input.int(70, title="RSI Overbought Level", minval=50, maxval=90)
rsi_lower = input.int(30, title="RSI Oversold Level", minval=10, maxval=50)

// ============ 2. CALCULATIONS ============
// EMA Speed Calculation
ema_value = ta.ema(close, length)
ema_past = ta.ema(close, length)[offset]
ema_speed = (ema_value - ema_past) / ema_past * 100

// RSI Calculation
rsi_value = ta.rsi(close, rsi_length)

// Squeeze Zone Calculation (Near Zero Momentum)
near_zero = math.abs(ema_speed) < 0.05

// ============ 3. VISUALIZATION ============

// A) EMA Speed (Colored Line)
speed_color = ema_speed > 0 ? color.green : color.red
plot(ema_speed, color=speed_color, title="EMA Speed", linewidth=2, style=plot.style_line)

// B) RSI (Scaled to fit the oscillator view)
rsi_scaled = (rsi_value / 50) - 1
plot(rsi_scaled, color=color.new(color.orange, 0), title="RSI (Scaled)", linewidth=2)

// C) Zero Reference Line
hline(0, color=color.new(color.gray, 50), title="Zero Line", linestyle=hline.style_dashed)

// D) RSI Overbought/Oversold Levels (Scaled)
rsi_ob_scaled = (rsi_upper / 50) - 1
rsi_os_scaled = (rsi_lower / 50) - 1
hline(rsi_ob_scaled, color=color.new(color.red, 30), title="RSI Overbought", linestyle=hline.style_dotted)
hline(rsi_os_scaled, color=color.new(color.green, 30), title="RSI Oversold", linestyle=hline.style_dotted)

// E) Squeeze Zone Background
bgcolor(near_zero ? color.new(color.purple, 85) : na, title="Flat / Squeeze Zone")

// ============ 4. STATUS TABLE (Top Right) ============
var table info_table = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 80), border_color=color.gray)

if barstate.islast
    // Row 1: EMA Speed
    table.cell(info_table, 0, 0, "EMA Speed:", text_color=color.white)
    table.cell(info_table, 1, 0, str.tostring(ema_speed, "#.##") + " %", text_color=ema_speed > 0 ? color.green : color.red)
    
    // Row 2: RSI Value
    table.cell(info_table, 0, 1, "RSI:", text_color=color.white)
    table.cell(info_table, 1, 1, str.tostring(rsi_value, "#.##"), text_color=rsi_value > rsi_upper ? color.red : rsi_value < rsi_lower ? color.green : color.gray)
    
    // Row 3: Trend Status
    table.cell(info_table, 0, 2, "Trend:", text_color=color.white)
    table.cell(info_table, 1, 2, ema_speed > 0.05 ? "RISING ▲" : ema_speed < -0.05 ? "FALLING ▼" : "FLAT (Squeeze)", text_color=ema_speed > 0.05 ? color.green : ema_speed < -0.05 ? color.red : color.yellow)
````
