# ADX Flaeche (TIG)

- url: https://www.tradingview.com/script/FWSGEMTG/
- type: indicator
- pine_id: PUB;dc9a78305a3440a099af8cebe7616d86
- version: 1.0

## Description

Here is a professional and concise description for your TradingView script, written in English.

ADX Area (SMA) with Price Scale
This indicator provides a clean, visual representation of trend strength using the Average Directional Index (ADX). Unlike the standard Wilder’s smoothing, this version utilizes a Simple Moving Average (SMA) for the final ADX calculation, making it slightly more responsive to recent price changes while maintaining clarity.

How it works:
Trend Strength Visualization: The indicator plots the ADX as an area chart.

Dynamic Coloring: When the ADX rises above the user-defined threshold (default is 20), the area turns Blue, signaling a strengthening trend. When below the threshold, the area remains Gray, indicating a weak trend or sideways market.

Integrated Price Scale: Designed specifically to keep your workspace organized, the current ADX value is displayed clearly on the price scale (y-axis) for quick reference.

Key Features:
Customizable Length: Adjust the lookback period for the ADX calculation.

Adjustable Threshold: Define your own "trend vs. range" boundary (e.g., 20 or 25).

Visual Clarity: The shaded area allows you to see at a glance whether the market is gaining momentum or losing steam without cluttering your main price chart.

How to use:
Blue Area: Look for potential trend-following entries as the trend intensity increases.

Gray Area: Exercise caution or look for mean-reversion strategies during low-volatility periods.

Slope: A rising ADX indicates an accelerating trend (regardless of direction), while a falling ADX suggests a weakening trend.

Settings:

ADX Length: 14 (Default)

Trend Threshold: 20 (Default)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gemini_AI

//@version=5
indicator("ADX Fläche (SMA) mit Preisskala", overlay=false, precision=2)

// --- Eingaben ---
len = input.int(14, title="ADX Länge")
th = input.int(20, title="Schwellenwert (Trend)")

// --- Manuelle Berechnung (SMA-Logik für Wert 33,4) ---
tr = math.max(math.max(high - low, math.abs(high - nz(close[1]))), math.abs(low - nz(close[1])))

dmPlus = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
dmMinus = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0) : 0

smoothedTR = 0.0
smoothedTR := nz(smoothedTR[1]) - (nz(smoothedTR[1]) / len) + tr

smoothedPlus = 0.0
smoothedPlus := nz(smoothedPlus[1]) - (nz(smoothedPlus[1]) / len) + dmPlus

smoothedMinus = 0.0
smoothedMinus := nz(smoothedMinus[1]) - (nz(smoothedMinus[1]) / len) + dmMinus

diPlus = (smoothedPlus / smoothedTR) * 100
diMinus = (smoothedMinus / smoothedTR) * 100

dx = math.abs(diPlus - diMinus) / (diPlus + diMinus) * 100

// Hier wird der SMA verwendet, um den schnelleren ADX zu erhalten
adxValue = ta.sma(dx, len)

// --- Visuelle Darstellung ---
areaColor = adxValue > th ? color.new(color.blue, 50) : color.new(color.gray, 85)

// Basislinie für die Füllung (auf display.none verzichtet, damit Skala aktiv bleibt)
plot0 = plot(0, "Null-Linie", color=color.new(color.gray, 100)) 

// ADX Plot - Ohne 'display=display.none', damit der Wert rechts in der Skala erscheint
plotADX = plot(adxValue, title="ADX Aktuell", color=color.new(color.gray, 20), linewidth=2)

// Füllung
fill(plot0, plotADX, color=areaColor, title="ADX Hintergrund-Füllung")

// Schwellenwert-Linie
hline(th, "Trendgrenze (20)", color=color.gray, linestyle=hline.style_dashed)
````
