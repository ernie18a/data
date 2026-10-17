# CATWA Daily Levels

- url: https://www.tradingview.com/script/HG4G7grn-CATWA-Daily-Levels/
- type: indicator
- pine_id: PUB;92c2b389d35b42b6b13569b5981a93c6
- version: 1.0

## Description

CATWA Daily Levels

A simple and lightweight indicator for plotting custom daily support, resistance, and decision levels.

Features
🌸 Up to 5 customizable resistance levels.
💎 Up to 5 customizable support levels.
👀 Highlighted decision/wait zone between two user-defined prices.
🎨 Clean chart with customizable inputs.
⚡ No repainting.
⚡ Extremely lightweight.
How to Use
Enter your daily support and resistance prices in the settings.
Update the values each trading day.
Watch price reaction around the levels.
The highlighted zone represents an area where waiting for confirmation may be preferable before entering a trade.

This indicator does not generate buy or sell signals. It is designed as a visual planning tool to help traders organize their daily key price levels.

Disclaimer: This script is for educational purposes only and should not be considered financial advice. Always perform your own analysis and risk management before trading.

## Source Code

````pine
//@version=6
indicator("CATWA Daily Levels", overlay=true)

// Prices
r1 = input.float(4080.01, "🌸 Resistance 1")
r2 = input.float(4096, "🌸 Resistance 2")
r3 = input.float(4112.01, "🌸 Resistance 3")
r4 = input.float(4128.06, "🌸 Resistance 4")
r5 = input.float(4144.14, "🌸 Resistance 4")

waitHigh = input.float(4064.06, "👀 Wait Zone High")
waitLow  = input.float(4048.14, "👀 Wait Zone Low")

s1 = input.float(4032.25, "💎 Support 1")
s2 = input.float(4016.39, "💎 Support 2")
s3 = input.float(4000.56, "💎 Support 3")
s4 = input.float(3984.76, "💎 Support 4")
s5 = input.float(3969, "💎 Support 5")

// Colors
pinkColor = color.rgb(214, 118, 167)
blueColor = color.rgb(76, 164, 170)

// Lines
hline(r1, "R1", color=pinkColor, linewidth=2)
hline(r2, "R2", color=pinkColor, linewidth=2)
hline(r3, "R3", color=pinkColor, linewidth=2)
hline(r4, "R4", color=pinkColor, linewidth=2)
hline(r5, "R4", color=pinkColor, linewidth=2)

hline(waitHigh, "Wait Zone High", color=color.white, linestyle=hline.style_dashed, linewidth=2)
hline(waitLow, "Wait Zone Low", color=color.white, linestyle=hline.style_dashed, linewidth=2)

hline(s1, "S1", color=blueColor, linewidth=2)
hline(s2, "S2", color=blueColor, linewidth=2)
hline(s3, "S3", color=blueColor, linewidth=2)
hline(s4, "S4", color=blueColor, linewidth=2)
hline(s5, "S5", color=blueColor, linewidth=2)

// Wait zone background
bgcolor(close <= waitHigh and close >= waitLow ? color.new(color.gray, 80) : na)
````
