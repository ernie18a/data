# Westernhagen Cloud

- url: https://www.tradingview.com/script/NWMfNpct-Westernhagen-Cloud/
- type: indicator
- pine_id: PUB;9f78e9add565474ca3e5bb899e46b3af
- version: 2.0

## Description

Best BTC Indicator - Daily / Weekly

Overview

The Westernhagen Cloud Pro 5 is a powerful, visually intuitive trend-following indicator designed to help traders identify market direction, filter out market noise, and pinpoint high-probability dynamic support and resistance zones. Built for clarity, it transforms complex price action into an easy-to-read, color-coded ribbon on your chart.

Key Features

Visual Trend Identification: The indicator plots a dynamic cloud that shifts color based on the prevailing trend. A solid, bright band (e.g., yellow) highlights a confirmed uptrend, while a transition to darker tones (e.g., grey/purple) acts as an early warning sign of fading momentum or a bearish reversal.

Dynamic Support & Resistance: Unlike traditional static lines, the Westernhagen Line breathes with the market. During strong trends, the edges of the ribbon act as highly reliable dynamic support (in an uptrend) or resistance (in a downtrend), offering perfect areas for "buy the dip" or "sell the rip" strategies.

Volatility Squeeze & Expansion: The width of the line visualizes market volatility. The band expands during aggressive trending moves and contracts (squeezes) during consolidation, helping traders anticipate upcoming breakouts.

Noise Reduction: By smoothing out erratic price spikes, the Westernhagen Line prevents traders from getting "whipsawed" out of positions prematurely, allowing you to ride macro trends for maximum profitability.

How to Use It

Trend Confirmation: Use the indicator as a directional filter. Only look for long setups (like bull flags or chart patterns) when the price is trading above a bullish-colored Westernhagen Line.

Breakout Trading: A decisive candle close through the entire width of the line, accompanied by a color shift, often signals a major trend reversal.

Confluence: It works exceptionally well when combined with traditional price action trading, chart patterns (as seen in the descending channels), and horizontal key levels.

## Source Code

````pine
//@version=6
indicator("Tideline 2", overlay=true)

// --- Einstellungen ---
// HL2 (High + Low / 2) glättet das Rauschen der Kerzen zusätzlich
src = hl2

// Typische Längen für die 4 geglätteten Durchschnitte
len1 = input.int(15, title="Länge 1 (Schnell)")
len2 = input.int(19, title="Länge 2")
len3 = input.int(25, title="Länge 3")
len4 = input.int(29, title="Länge 4 (Langsam)")

// --- Berechnung der Smoothed Moving Averages (RMA in Pine Script) ---
ma1 = ta.rma(src, len1)
ma2 = ta.rma(src, len2)
ma3 = ta.rma(src, len3)
ma4 = ta.rma(src, len4)

// --- Trend-Logik (Die Sortierung der Linien) ---
// Nur wenn alle 4 Linien perfekt sortiert sind, haben wir einen klaren Trend
isBullish = (ma1 > ma2) and (ma2 > ma3) and (ma3 > ma4)
isBearish = (ma1 < ma2) and (ma2 < ma3) and (ma3 < ma4)

// --- Tideline Farben (direkt aus dem Logo gesampelt) ---
// Marken-Teal #8CE4E1 (Farbton 178°)  +  Komplementär-Koralle #E48184 (Farbton 358°)
colorTeal  = color.new(#8CE4E1, 40) // statt Gelb  -> Marken-Teal (bullish)
colorCoral = color.new(#E48184, 40) // statt Lila  -> Komplementär-Koralle (bearish)
colorSlate = color.new(#5E7372, 60) // gedämpftes Slate für den Übergang (passt zum Navy)

// Füllfarbe basierend auf der Sortierung
cloudColor = isBullish ? colorTeal : isBearish ? colorCoral : colorSlate

// Linienfarbe für die äußeren Ränder (etwas kräftiger als die Wolke)
lineColor = isBullish ? #5FD3CF : isBearish ? #E0686D : #5E7372

// --- Zeichnen des Schlauchs ---
// Wir zeichnen nur die schnellste und die langsamste Linie als Rand
p_fast = plot(ma1, color=lineColor, linewidth=1, title="Schneller Rand")
p_slow = plot(ma4, color=lineColor, linewidth=1, title="Langsamer Rand")

// Den Raum dazwischen füllen
fill(p_fast, p_slow, color=cloudColor, title="Schlauch")
````
