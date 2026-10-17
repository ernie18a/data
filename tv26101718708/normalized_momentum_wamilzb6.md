# Normalized Momentum 

- url: https://www.tradingview.com/script/WamiLzB6-Normalized-Momentum/
- type: indicator
- pine_id: PUB;c08a97f674d842dda2bd2026229cc768
- version: 1.0

## Description

Indicator Description:  
This indicator is designed to help traders identify market structure, trend direction, volatility conditions, and potential reversal zones. It combines price‑action logic with dynamic calculations to highlight key areas of interest and improve decision‑making across different timeframes.

The tool automatically analyzes recent price behavior and visualizes important signals such as trend shifts, momentum changes, breakout conditions, and support/resistance reactions. It can be used for scalping, intraday trading, swing trading, or long‑term analysis.

Key Features:

Detects trend direction and potential trend reversals

Highlights important support and resistance zones

Identifies momentum strength and volatility changes

Works on all markets (Forex, Crypto, Stocks, Indices, Commodities)

Fully customizable parameters for fine‑tuning

Suitable for beginners and advanced traders

Helps filter noise and improve entry/exit timing

How to Use:

Look for confluence between trend direction, momentum, and price reaction

Use signals as confirmation, not as a standalone entry trigger

Combine with volume, market structure, or higher‑timeframe analysis

Adjust sensitivity based on your trading style

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rauser

//@version=5
indicator("Normalized Momentum ", overlay=false)

// Přidání indikátoru momentum
momentum_length = 14
momentum = close - close[momentum_length]

// Normalizace momenta
lowest_momentum = ta.lowest(momentum, momentum_length)
highest_momentum = ta.highest(momentum, momentum_length)
normalized_momentum = (momentum - lowest_momentum) / (highest_momentum - lowest_momentum)

// Prevent division by zero
normalized_momentum := (highest_momentum != lowest_momentum) ? normalized_momentum : 0.0



// Vykreslení normalizovaného momentum
plot(normalized_momentum, title="Normalized Momentum", color=color.purple)

// Přidání nuly pro lepší viditelnost
hline(0, "Zero Line", color=color.gray)
hline(1, "Max Line", color=color.gray, linestyle=hline.style_dashed)

// Druhé normalizované momentum (např. s jiným délkou)
momentum_length_2 = 28
momentum_2 = close - close[momentum_length_2]
lowest_momentum_2 = ta.lowest(momentum_2, momentum_length_2)
highest_momentum_2 = ta.highest(momentum_2, momentum_length_2)
normalized_momentum_2 = (momentum_2 - lowest_momentum_2) / (highest_momentum_2 - lowest_momentum_2)
normalized_momentum_2 := (highest_momentum_2 != lowest_momentum_2) ? normalized_momentum_2 : 0.0

// Vykreslení druhého normalizovaného momentum
plot(normalized_momentum_2, title="Normalized Momentum 2", color=color.blue)
````
