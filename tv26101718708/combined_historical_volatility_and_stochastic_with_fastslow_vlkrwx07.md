# Combined Historical Volatility and Stochastic with Fast/Slow

- url: https://www.tradingview.com/script/VlkRwx07-Combined-Historical-Volatility-and-Stochastic-with-Fast-Slow/
- type: indicator
- pine_id: PUB;d3d30da8c0834068b011403fc18e43d5
- version: 1.0

## Description

Combined Historical Volatility & Fast/Slow Stochastic
Combined Historical Volatility and Stochastic with Fast/Slow is a multi‑purpose momentum and volatility indicator designed to give traders a deeper understanding of market conditions. It merges two essential analytical components—Fast/Slow Stochastic oscillators and Normalized Historical Volatility—into a single, easy‑to‑read panel.

🎯 Key Features
1. Fast & Slow Stochastic Oscillators
The script calculates and plots two independent Stochastic structures:

Fast Stochastic (%K Fast / %D Fast)  
Highly responsive, ideal for short‑term momentum shifts.

Slow Stochastic (%K Slow / %D Slow)  
Smoothed version for cleaner, more stable signals.

Both are displayed together, allowing traders to compare short‑term vs. medium‑term momentum dynamics.

2. Normalized Historical Volatility
The indicator computes Historical Volatility using:

Standard deviation of price

EMA smoothing

Normalization into a 0–100 scale

This normalization allows volatility to be plotted in the same panel as the Stochastic oscillators, making it easy to see whether signals occur during high‑volatility or low‑volatility environments.

📈 What You Can Identify
Overbought and oversold zones (20/80 levels)

Agreement or divergence between Fast and Slow Stochastic

Volatility spikes that may confirm or invalidate momentum signals

Market conditions where momentum signals are more reliable

Trend exhaustion, reversals, and consolidation phases

🧠 Practical Use Cases
Filtering Stochastic signals using volatility

Detecting high‑probability reversal zones

Timing entries during volatility expansions

Avoiding trades during low‑volatility noise

Works on all markets: Forex, Crypto, Stocks, Indices, Commodities

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rauser

//@version=5
indicator("Combined Historical Volatility and Stochastic with Fast/Slow", overlay=false)

// Parametry pro stochastický oscilátor
kLength = input(14, title="Stochastic %K Length")
dLengthFast = input(3, title="Fast Stochastic %D Length")
dLengthSlow = input(5, title="Slow Stochastic %D Length")

// Výpočet rychlého stochastického indikátoru
kFast = ta.stoch(close, high, low, kLength)
dFast = ta.sma(kFast, dLengthFast)

// Výpočet pomalého stochastického indikátoru
kSlow = ta.stoch(close, high, low, kLength)
dSlow = ta.sma(kSlow, dLengthSlow)

// Vykreslení rychlého stochastického indikátoru
plot(kFast, color=color.blue, title="%K Fast", linewidth=2)
plot(dFast, color=color.red, title="%D Fast", linewidth=2)

// Vykreslení pomalého stochastického indikátoru
plot(kSlow, color=color.green, title="%K Slow", linewidth=2)
plot(dSlow, color=color.orange, title="%D Slow", linewidth=2)

// Hranice 20 a 80 pro překoupené a přeprodané úrovně
hline(20, "Oversold", color=color.green, linestyle=hline.style_dashed)
hline(80, "Overbought", color=color.red, linestyle=hline.style_dashed)

// Parametry pro historickou volatilitu
volLength = input(20, title="Volatility Length")
hvMultiplier = input(100, title="Historical Volatility Multiplier")

// Výpočet historické volatility (standardní odchylka)
historicalVolatility = ta.ema(ta.stdev(close, volLength), volLength) * hvMultiplier

// Normalizace volatility pro zobrazení na stejném grafu
normalizedVolatility = 100 * (historicalVolatility - ta.lowest(historicalVolatility, volLength)) / (ta.highest(historicalVolatility, volLength) - ta.lowest(historicalVolatility, volLength))

// Ochrana proti dělení nulou
normalizedVolatility := na(normalizedVolatility) ? 0 : normalizedVolatility

// Vykreslení historické volatility
plot(normalizedVolatility, color=color.purple, title="Normalized Historical Volatility", linewidth=2)

// Přidání horizontálních linií pro referenci
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
hline(100, "Max Volatility Line", color=color.gray, linestyle=hline.style_dashed)
````
