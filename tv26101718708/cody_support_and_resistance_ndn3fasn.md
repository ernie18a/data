# Cody Support and Resistance

- url: https://www.tradingview.com/script/nDN3FAsn-Cody-Support-and-Resistance/
- type: indicator
- pine_id: PUB;68301a5af78847d5acb82d440c8c5b4b
- version: 1.0

## Description

Cody Support & Resistance - Automatic S/R levels based on Bill Williams Fractals. Identifies key support/resistance zones with breakout alerts.

Description (Full)
📊 Overview
This indicator automatically plots Support and Resistance levels using Bill Williams Fractal logic. It helps traders identify key price zones where reversals or breakouts are likely to occur.

🔑 Key Features
Automatic S/R Levels - Fractal-based support (green) and resistance (red) levels

Visual Fractals - Blue circles for down fractals, orange circles for up fractals

Breakout Alerts - Get notified when price breaks above resistance or below support

Customizable Periods - Adjust the fractal sensitivity with the "Periods" input (default: 2)

🎯 How It Works
Resistance (Red Line) - Forms when price makes a lower high on both sides (down fractal)

Support (Green Line) - Forms when price makes a higher low on both sides (up fractal)

Breakout Buy Alert - Triggers when price closes above resistance

Breakdown Sell Alert - Triggers when price closes below support

📈 How to Use
Add to your chart

Look for green (support) and red (resistance) horizontal levels

Price bouncing off support → potential long entry

Price rejecting resistance → potential short entry

Price breaking through → trend continuation signal

⚙️ Settings
Periods - Number of bars on each side of the fractal (higher = fewer, stronger levels)

📣 Alerts Available
Breakout Buy - Price broke resistance

Breakdown Sell - Price broke support

🙏 Credits
Original fractal logic: Matthew Spencer

Support/resistance adaptation: Kunal Patel

Compiled by: Cody

🔔 Tags (for TradingView publishing)
Support and Resistance Fractals Breakout Levels Swing Trading Price Action

Would you like me to adjust the tone (more technical, simpler, shorter) or add anything else?

## Source Code

````pine
//@version=6
// Cody Support and Resistance
// Based on Bill Williams Fractal Template
// Initially Coded By: Matthew Spencer (Fractals)
// Updated by Kunal Patel - Based on Support and Resistance (Barry)

// If you like this script or use it's code in one of yours, please donate to Matthew Spancer. I did it for free.
// PayPal: ma.spencer@gmx.com Bitcoin: 1foxypuyuoNp5n1LNCCCCmjZ4RAXntQ8X

indicator("Cody Support and Resistance", shorttitle="Cody_SR Levels", overlay=true)

// Define "n" as the number of periods and keep a minimum value of 2 for error handling.
n = input.int(title="Periods", defval=2, minval=2)

// Fractal detection (preserving original logic)
var float dnFractal = na
var float upFractal = na

dnFractal := (high[n-2] < high[n]) and (high[n-1] < high[n]) and (high[n+1] < high[n]) and (high[n+2] < high[n]) ? high : dnFractal[1]
upFractal := (low[n-2] > low[n]) and (low[n-1] > low[n]) and (low[n+1] > low[n]) and (low[n+2] > low[n]) ? low : upFractal[1]

// Plot the fractals as shapes on the chart (original style)
plotshape(dnFractal, title="D", style=shape.circle, location=location.absolute, color=color.new(color.blue, 10))
plotshape(upFractal, title="U", style=shape.circle, location=location.absolute, color=color.new(color.orange, 10))

// Plot SUPPORT and RESISTANCE LEVELS as horizontal lines
plot(dnFractal, title="Resistance Level", color=color.new(color.red, 0), linewidth=2, style=plot.style_circles)
plot(upFractal, title="Support Level", color=color.new(color.green, 0), linewidth=2, style=plot.style_circles)

// Buy/Sell alerts based on fractal breaks
buySignal = close > dnFractal and dnFractal == dnFractal[1]  // Price breaks above resistance
sellSignal = close < upFractal and upFractal == upFractal[1]  // Price breaks below support

alertcondition(buySignal, title="Breakout Buy", message="Price broke resistance!")
alertcondition(sellSignal, title="Breakdown Sell", message="Price broke support!")
````
