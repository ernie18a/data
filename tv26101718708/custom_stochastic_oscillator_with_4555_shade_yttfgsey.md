# Custom Stochastic Oscillator with 45-55 Shade

- url: https://www.tradingview.com/script/yTTfgSEY-Custom-Stochastic-Oscillator-with-45-55-Shade/
- type: indicator
- pine_id: PUB;a5feca52f42d438bb048be372f5dee83
- version: 1.0

## Description

Custom Stochastic Oscillator designed specifically for momentum and cycle trading. 

Features:
- Configured to the standard 5, 2, 3 calculation settings.
- Clearly displays the standard 20 and 80 extreme momentum zones.
- Features a custom shaded neutral background zone running between the 45 and 55 levels to easily identify messy or choppy market conditions at a glance.

## Source Code

````pine
//@version=6
indicator("Top Dog Stochastic with 45-55 Shade", shorttitle="Top Dog Stoch", overlay=false)

// Inputs exactly matching your 5, 2, 3 settings
kLength = input.int(5, title="Stochastic Length")
kSmoothing = input.int(2, title="Smooth K")
dSmoothing = input.int(3, title="Smooth D")

// Strategy Line Level Calculations
kLine = ta.sma(ta.stoch(close, high, low, kLength), kSmoothing)
dLine = ta.sma(kLine, dSmoothing)

// Plot the strategy lines (Black for %K, Blue for %D)
plot(kLine, color=color.black, linewidth=2, title="%K (Fast Line)")
plot(dLine, color=color.blue, linewidth=2, title="%D (Slow Line)")

// Draw the standard 20 and 80 course level lines
hline(80, "Overbought (80)", color=color.gray, linestyle=hline.style_dashed)
hline(20, "Oversold (20)", color=color.gray, linestyle=hline.style_dashed)

// Create the 45 and 55 lines to generate the custom shading
noManTop = hline(55, "Neutral Top (55)", color=color.new(color.red, 30), linestyle=hline.style_dotted)
noManBot = hline(45, "Neutral Bottom (45)", color=color.new(color.red, 30), linestyle=hline.style_dotted)

// Paint the 45-55 "No Man's Zone" background red with 92% transparency
fill(noManTop, noManBot, color=color.new(color.red, 92), title="No Man's Zone Shading")
````
