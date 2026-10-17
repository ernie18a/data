# Stoch RSI - (Crossover Visual Upgrade)

- url: https://www.tradingview.com/script/5GWSBKV8-Stoch-RSI-Crossover-Visual-Upgrade/
- type: indicator
- pine_id: PUB;6abf7c14a6954c47a586328279db4699
- version: 1.0

## Description

Stochastic RSI (Crossover Visual Upgrade) - Enhanced Momentum Indicator

This script is an optimized version of the standard Stochastic RSI. While maintaining the familiar logic of the original indicator, I have introduced a dynamic color-coding system for the K-line to help traders instantly identify momentum shifts and crossovers.

Why this version is useful:
In fast-paced markets, distinguishing between bullish and bearish momentum on a standard Stochastic RSI can be difficult. This version simplifies the process by automatically changing the color of the Fast K-line:

Blue: Indicates the Fast line (K) is above the Slow line (D), signaling potential bullish momentum.

Red: Indicates the Fast line (K) is below the Slow line (D), signaling potential bearish momentum.

This visual upgrade helps reduce eye strain and allows you to make quicker trading decisions without needing to closely track line overlaps.

Key Features:

Dynamic Color-Coding: Real-time color updates for the K-line based on its position relative to the D-line.

Clean Visuals: Retains the classic bands and structure while improving readability for day trading.

Lightweight & Efficient: Optimized for performance so it won't clutter your chart.

How to use:
Simply add the indicator to your chart. The Fast K-line will change color dynamically as it crosses the Slow D-line, giving you an immediate visual confirmation of the current momentum direction.

Author's Note:
I created this visual upgrade because I prefer a cleaner look when monitoring stochastic crossovers during fast trades. I wanted to remove the guesswork when glancing at the indicator. Since I found it very helpful for my own setup, I decided to share it with the community. Big thanks to Gemini for helping me craft this description. I hope you find this useful!

## Source Code

````pine
//@version=6
indicator(title="Stoch RSI - (Crossover Visual Upgrade)", shorttitle="Stoch RSI - (Crossover Visual Upgrade)", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// --- Inputs ---
smoothK = input.int(3, "K", minval=1)
smoothD = input.int(3, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)
src = input(close, title="RSI Source")

// --- Calculations ---
rsi1 = ta.rsi(src, lengthRSI)
k = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = ta.sma(k, smoothD)

// --- Dynamic Color Logic ---
// Use a var variable to store the last color (default to blue)
var color kColor = color.blue 

// Update color only when a crossover occurs
if (k > d)
    kColor := color.blue
else if (k < d)
    kColor := color.red
// If k == d, maintain the previous color value

// --- Plotting ---
plot(d, "D (Slow)", color=color.white, linewidth=1) 
plot(k, "K (Fast)", color=kColor, linewidth=2) 

// --- Bands ---
h0 = hline(80, "Upper Band", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
h1 = hline(20, "Lower Band", color=#787B86)
fill(h0, h1, color=color.rgb(33, 150, 243, 90), title="Background")
````
