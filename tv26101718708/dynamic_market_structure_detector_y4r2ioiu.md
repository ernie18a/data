# Dynamic Market Structure Detector

- url: https://www.tradingview.com/script/y4R2iOIU-Dynamic-Market-Structure-Detector/
- type: indicator
- pine_id: PUB;c669239d5b4c482cb65faa6a9d5f630f
- version: 1.0

## Description

[b]Title: [/b]Dynamic Market Structure Detector – Real-Time BoS & ChoCH Signals

[b]Short Description:[/b]

Identify market structure dynamically with real-time Break of Structure (BoS) and Change of Character (ChoCH) signals. Highlight untested support and resistance zones to improve trading precision.

[b]Full Description:[/b]

The Dynamic Market Structure Detector is a powerful TradingView indicator designed for traders who want to automate the identification of key market structure levels. This indicator simplifies market analysis by dynamically tracking swing highs and lows, marking critical Break of Structure (BoS) and Change of Character (ChoCH) points, and highlighting untested support and resistance zones.

[b]Key Features:[/b]
	1.	Real-Time Signals:
	•	Marks Break of Structure (BoS) and Change of Character (ChoCH) points as they occur.
	•	Automatically updates as the market evolves.
	2.	Dynamic Swing Highs and Lows:
	•	Tracks swing highs and lows based on user-defined sensitivity (Swing Length).
	•	Adjust swing length to tailor signals for intraday or swing trading.
	3.	Untested Zones Highlight:
	•	Visualize untested support and resistance zones dynamically.
	•	Opacity settings allow customization for better chart readability.
	4.	Customizable Inputs:
	•	Swing Length:
Adjust the sensitivity of BoS and ChoCH signals.
	•	Smaller Swing Length values (e.g., 3–5): Capture short-term market movements, ideal for intraday trading.
	•	Larger Swing Length values (e.g., 10–20): Focus on significant market structure changes for swing or positional trading.
Experiment with these values to find the best fit for your trading style.
	•	Untested Zone Opacity:
Control the visibility of highlighted support and resistance zones.
	•	Lower opacity values (e.g., 10–50): Make the zones more prominent, helpful for darker chart backgrounds.
	•	Higher opacity values (e.g., 70–90): Provide subtle highlights, better suited for lighter chart setups.
	•	A value of 100% renders the zones completely transparent (invisible).
Use this setting to customize the visual appearance of your chart while still retaining key zone information.
	5.	User-Friendly Visualization:
	•	Color-coded labels for BoS (Green) and ChoCH (Red).
	•	Highlight zones for untested areas using customizable colors (Support: Blue, Resistance: Orange).

[b]Why Use This Indicator?[/b]
	•	Simplifies market structure analysis by automating key calculations.
	•	Helps traders identify potential trend reversals and continuation points.
	•	Reduces the need for manual charting, saving time and effort.
	•	Provides visual clarity on untested zones for better decision-making.

[b]Recommended Usage:[/b]
	•	Intraday Traders: Use smaller Swing Length values (e.g., 3–5) to capture short-term market movements.
	•	Swing Traders: Opt for higher Swing Length values (e.g., 10–20) to focus on larger market structure changes.
	•	Monitor untested zones for potential price reactions, enhancing your trade entries and exits.

[b]Notes[/b]:

This indicator is best suited for traders who prefer price action trading and market structure analysis. While the indicator provides reliable insights, it is recommended to use it in conjunction with other analysis tools for a holistic trading approach.

[b]Credits:[/b]

Developed by TradeTech Analysis to empower traders with automated tools for smarter trading decisions.

## Source Code

````pine
//@version=6
indicator("Dynamic Market Structure Detector", overlay=true)

// Inputs for the indicator
var float swingHigh = na
var float swingLow = na

bosColor = color.new(color.green, 0)
chochColor = color.new(color.red, 0)
supportColor = color.new(color.blue, 60)
resistanceColor = color.new(color.orange, 60)

length = input.int(3, "Swing Length", minval=1)
untestedZoneOpacity = input.int(80, "Untested Zone Opacity", minval=10, maxval=100)

// Function to identify swing highs and lows
isSwingHigh = ta.highest(high, length) == high[length]
isSwingLow = ta.lowest(low, length) == low[length]

if (isSwingHigh)
    swingHigh := high[length]
if (isSwingLow)
    swingLow := low[length]

// BoS and ChoCH logic
bos = ta.cross(close, swingHigh)
choch = ta.cross(close, swingLow)

// Plot Break of Structure (BoS) and Change of Character (ChoCH)
if (bos)
    label.new(bar_index, swingHigh, text="BoS", style=label.style_label_down, color=bosColor, textcolor=color.white, size=size.tiny)
if (choch)
    label.new(bar_index, swingLow, text="ChoCH", style=label.style_label_up, color=chochColor, textcolor=color.white,size=size.tiny)

// Highlight untested zones
var color globalSupportColor = na
var color globalResistanceColor = na
if (isSwingLow)
    globalSupportColor := color.new(supportColor, untestedZoneOpacity)
if (isSwingHigh)
    globalResistanceColor := color.new(resistanceColor, untestedZoneOpacity)

bgcolor(globalSupportColor)
bgcolor(globalResistanceColor)

// Dynamic swing highs and lows
plot(swingHigh, "Swing High", color=color.green, linewidth=2, style=plot.style_circles)
plot(swingLow, "Swing Low", color=color.red, linewidth=2, style=plot.style_circles)

// Table for displaying statistics
table stats = table.new(position.top_right, 1, 3)
table.cell(stats, 0, 0, "Dynamic Market Structure", bgcolor=color.black, text_color=color.white)
table.cell(stats, 0, 1, "BoS Points", bgcolor=color.green, text_color=color.white)
table.cell(stats, 0, 2, "ChoCH Points", bgcolor=color.red, text_color=color.white)
````
