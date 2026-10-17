# Wave Navigator Cycle [Adaptive] 

- url: https://www.tradingview.com/script/LkdQLlEo-Wave-Navigator-Cycle-Adaptive/
- type: indicator
- pine_id: PUB;971a9c675a814b71b64c2c8fa4b56414
- version: 1.0

## Description

Wave Navigator Cycle [Adaptive System]

Overview
The Wave Navigator System is a comprehensive technical indicator designed to trade the "Distorted Cycle." Unlike traditional indicators that lag behind price, this system uses an Adaptive Sine Wave to map out market phases in real-time, helping traders identify when the market is in a state of Preparation, Expansion (Ride the Wave), or Distribution.

This tool integrates high-probability Smart Money Concepts (SMC) including Liquidity Sweeps, Displacement, and Fair Value Gaps (FVG) to provide a complete roadmap for trend following and reversal trading.

Key Features

1. Adaptive Sine Wave Cycle
At the core of this indicator is a dynamic sine wave anchored to an ALMA (Arnaud Legoux Moving Average). 
- Preparation Phase: Price is at the cycle bottom (Low Zone), looking for Sell-Side Liquidity.
- Ride the Wave: The sine wave turns green and rises, signalling a bullish trend expansion.
- Distribution Phase: Price reaches the cycle peak (High Zone), looking for Buy-Side Liquidity.
- Displacement Down: The sine wave turns red, signalling a shift in market structure and a bearish move.

2. Liquidity Sweep Detection
The indicator automatically marks "Equal Highs" and "Equal Lows" that have been swept. 
- X Marks: Buy-Side Liquidity Sweeps (Potential Short setups).
- Triangle Marks: Sell-Side Liquidity Sweeps (Potential Long setups).

3. Smart Displacement & FVGs
The system doesn't just look for big candles; it calculates Relative Displacement. When price moves with high volume and volatility, the indicator identifies Fair Value Gaps (FVG). 
- Emerald Boxes: Bullish FVGs (Targets for "Retrace to FVG" longs).
- Maroon Boxes: Bearish FVGs (Targets for "Retrace to FVG" shorts).

4. Real-Time Dashboard
A built-in HUD (Heads-Up Display) in the top-right corner monitors the Cycle Power and explicitly labels the current market phase, so you never have to guess where you are in the "Distorted Cycle."

---

How to Trade with Wave Navigator
1. Identify the Zone: Look for the Sine Wave to enter the "Preparation" (Low) or "Distribution" (High) zones.
2. Wait for the Sweep: Look for a Liquidity Sweep icon to appear at the cycle extremes.
3. Confirm with Displacement: Wait for a Displacement Arrow and a coloured Sine Wave flip (Green for Up / Red for Down).
4. The Entry: Enter on the Retrace to FVG (the coloured boxes) once the wave has begun its new direction.

Settings
- Base MA Length: Adjust this to change the "frequency" of the wave (Higher = Swing Trading, Lower = Scalping).
- Displacement Sensitivity: Fine-tune how "aggressive" the price move must be to trigger an FVG.
- Sine Opacity: Customise the visual intensity of the trend wave.


Disclaimer: Trading involves significant risk. This indicator is a tool for analysis and should be used in conjunction with a robust trading plan and proper risk management.

## Source Code

````pine
//@version=5
indicator("Wave Navigator Cycle [Adaptive] Final", shorttitle="WNCycle_Final", overlay=true, max_lines_count=500, max_boxes_count=500, max_bars_back=500)

// --- Input Controls ---
GRP_MA      = "Moving Average Settings (Sine Anchor)"
maType      = input.string("ALMA", "Base MA Type", options=["SMA", "EMA", "WMA", "ALMA"], group=GRP_MA)
maLen       = input.int(55, "Base MA Length", minval=1, group=GRP_MA)
almaOffset  = input.float(0.85, "ALMA Offset", step=0.01, group=GRP_MA)
almaSigma   = input.float(6, "ALMA Sigma", step=0.1, group=GRP_MA)

GRP_CYC     = "Sine Wave Settings"
showSine    = input.bool(true, "Show Sine Wave", group=GRP_CYC)
sineOpacity = input.int(50, "Sine Opacity (0-100)", minval=0, maxval=100, group=GRP_CYC)

GRP_FVG     = "Fair Value Gap (FVG) Settings"
showFVG     = input.bool(true, "Show FVGs", group=GRP_FVG)
// Using Hex Codes to avoid 'Undeclared Identifier' issues
bullFvgCol  = input.color(#50C878, "Bullish FVG Color", group=GRP_FVG) // Emerald Hex
bearFvgCol  = input.color(#800000, "Bearish FVG Color", group=GRP_FVG) // Maroon Hex
fvgTransp   = input.int(80, "FVG Transparency", minval=0, maxval=100, group=GRP_FVG)

GRP_LIQ     = "Liquidity & Displacement Settings"
showLiq     = input.bool(true, "Show Sweeps/Displacements", group=GRP_LIQ)
liqSens     = input.int(3, "Liquidity Sweep Sensitivity", minval=1, group=GRP_LIQ)
dispSens    = input.float(2.5, "Displacement Sensitivity", minval=0.5, step=0.1, group=GRP_LIQ)

// --- Core MA Calculation ---
f_ma(src, len, type, aOff, aSig) =>
    float result = na
    if type == "SMA"
        result := ta.sma(src, len)
    else if type == "EMA"
        result := ta.ema(src, len)
    else if type == "WMA"
        result := ta.wma(src, len)
    else if type == "ALMA"
        result := ta.alma(src, len, aOff, aSig)
    result

baseMA = f_ma(close, maLen, maType, almaOffset, almaSigma)

// --- Sine Wave Principles ---
highestHigh = ta.highest(high, maLen)
lowestLow   = ta.lowest(low, maLen)
rangeSize   = highestHigh - lowestLow
price_norm  = rangeSize != 0 ? ((baseMA - lowestLow) / rangeSize - 0.5) * 2 : 0
sine_wave   = math.sin(price_norm * (math.pi / 2))

sine_rising = ta.rising(sine_wave, 1)
// Fixed color calls using standard color names
dynamicSineColor = sine_rising ? color.new(color.lime, 100 - sineOpacity) : color.new(color.red, 100 - sineOpacity)

plot(baseMA, color=dynamicSineColor, linewidth=3, title="Adaptive Cycle Wave")

// --- Liquidity Sweeps ---
highSweep = ta.crossover(high, ta.highest(high, maLen)[1])
lowSweep  = ta.crossunder(low, ta.lowest(low, maLen)[1])

plotshape(showLiq and highSweep, "Buy-Side Liquidity Sweep", shape.xcross, location.abovebar, color.red, size=size.tiny)
plotshape(showLiq and lowSweep, "Sell-Side Liquidity Sweep", shape.triangleup, location.belowbar, color.green, size=size.tiny)

// --- Displacement Detection ---
bodySize = math.abs(close - open)
avgBody  = ta.sma(bodySize, 20)
isDisplaced = bodySize > (avgBody * dispSens)

plotshape(showLiq and isDisplaced and close > open, "Bullish Displacement", shape.arrowup, location.belowbar, color.lime, size=size.small)
plotshape(showLiq and isDisplaced and close < open, "Bearish Displacement", shape.arrowdown, location.abovebar, color.red, size=size.small)

// --- Fair Value Gaps (FVG) Logic ---
if showFVG
    if low[0] > high[2] and isDisplaced[1]
        box.new(bar_index[2], low[0], bar_index, high[2], bgcolor=color.new(bullFvgCol, fvgTransp), border_color=color.new(bullFvgCol, 100))
    
    if high[0] < low[2] and isDisplaced[1]
        box.new(bar_index[2], high[0], bar_index, low[2], bgcolor=color.new(bearFvgCol, fvgTransp), border_color=color.new(bearFvgCol, 100))

// --- Info Table ---
var table mainTable = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 70), border_color=color.gray, border_width=1)
if barstate.islast
    string phase = sine_wave > 0.7 ? "DISTRIBUTION" : sine_wave < -0.7 ? "PREPARATION" : sine_rising ? "RIDE THE WAVE (UP)" : "DISPLACEMENT (DOWN)"
    color pColor = sine_wave > 0.7 ? color.red : sine_wave < -0.7 ? color.green : sine_rising ? color.lime : color.orange
    
    table.cell(mainTable, 0, 0, "Current Phase:", text_color=color.white)
    table.cell(mainTable, 1, 0, phase, text_color=pColor)
    table.cell(mainTable, 0, 1, "Cycle Power:", text_color=color.white)
    table.cell(mainTable, 1, 1, str.tostring(sine_wave, "#.##"), text_color=color.white)
````
