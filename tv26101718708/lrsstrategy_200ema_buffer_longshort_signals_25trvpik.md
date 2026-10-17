# LRS-Strategy: 200-EMA Buffer & Long/Short Signals 

- url: https://www.tradingview.com/script/25trvpik/
- type: indicator
- pine_id: PUB;4e38764c42e4468ca9e5e628cba05d41
- version: 1.0

## Description

LRS-Strategy: 200-EMA Buffer & Long/Short Signals
This indicator is designed to help traders implement the Leveraged Return Strategy (LRS) using the 200-day Exponential Moving Average (EMA) as a key trend-following signal. The indicator offers clear long and short signals by analyzing the price movements relative to the 200-day EMA, enhanced by customizable buffer zones for increased precision.

Key Features:
200-Day EMA: The main trend indicator. When the price is above the 200-day EMA, the market is considered in an uptrend, and when it is below, it indicates a downtrend.
Customizable Buffer Zones: Users can define a percentage buffer around the 200-day EMA (default is 3%). The upper and lower buffer zones help filter out noise and prevent premature signals.
Precise Long/Short Signals:
Long Signal: Triggered when the price moves from below the lower buffer zone, crosses the 200-day EMA, and then breaks above the upper buffer zone.
Short Signal: Triggered when the price moves from above the upper buffer zone, crosses the 200-day EMA, and then breaks below the lower buffer zone.
Alternating Signals: Ensures that a new signal (long or short) is only generated after the opposite signal has been triggered, preventing multiple signals of the same type without a reversal.
Clear Visual Aids: The indicator displays the 200-day EMA and buffer zones on the chart, along with buy (long) and sell (short) signals. This makes it easy to track trends and time entries/exits.
How to Use:
Long Entry: Look for the price to move below the lower buffer, cross the 200-day EMA from below, and then break out of the upper buffer to confirm a long signal.
Short Entry: Look for the price to move above the upper buffer, cross below the 200-day EMA, and then break below the lower buffer to confirm a short signal.
This indicator is perfect for traders who prefer a structured, trend-following approach, using clear rules to minimize noise and identify meaningful long or short opportunities.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © k_j_witt

//@version=5
indicator("LRS-Strategy: 200-EMA & Long/Short Signals", overlay=true)

// =============================
// Benutzerdefinierte Eingaben
// =============================
percentUpper = input.float(3.0, title="Prozent oberes Band", minval=0.0, step=0.1)  // Standardwert 3%
percentLower = input.float(3.0, title="Prozent unteres Band", minval=0.0, step=0.1)  // Standardwert 3%

// =============================
// Berechnungen
// =============================

// Berechnung der 200-Tage EMA
ema200 = ta.ema(close, 200)

// Berechnung der oberen und unteren Bänder basierend auf den Benutzereingaben
upperBand = ema200 * (1 + percentUpper / 100)
lowerBand = ema200 * (1 - percentLower / 100)

// Plot der EMA Linie und der Bänder
plot_ema = plot(ema200, title="200-Tage EMA", color=color.blue, linewidth=2)
plot_upper = plot(upperBand, title="Oberes Band", color=color.green, linewidth=1, style=plot.style_line)
plot_lower = plot(lowerBand, title="Unteres Band", color=color.red, linewidth=1, style=plot.style_line)

// Fülle den Bereich zwischen der 200-Tage-EMA und den Bändern
fill(plot_ema, plot_upper, color=color.new(color.green, 90))  // Halbtransparente grüne Füllung oben
fill(plot_ema, plot_lower, color=color.new(color.red, 90))    // Halbtransparente rote Füllung unten

// =============================
// Sequenz-Flags
// =============================
var bool pendingLong = false
var bool readyLong = false
var bool pendingShort = false
var bool readyShort = false

// =============================
// Initialisierung der Signale
// =============================
longSignalCondition = false
shortSignalCondition = false

// =============================
// Long-Signal Sequenz
// =============================
// Schritt 1: Kreuzung unterhalb des unteren Puffers
if (ta.crossunder(close, lowerBand))
    pendingLong := true

// Schritt 2: Kreuzung oberhalb der 200-Tage-EMA
if (pendingLong and ta.crossover(close, ema200))
    readyLong := true

// Schritt 3: Kreuzung oberhalb des oberen Puffers
if (readyLong and ta.crossover(close, upperBand))
    longSignalCondition := true
    // Reset der Long-Flags nach Signal
    pendingLong := false
    readyLong := false
    // Reset der Short-Flags, um die Sequenz zu erzwingen
    pendingShort := false
    readyShort := false

// =============================
// Short-Signal Sequenz
// =============================
// Schritt 1: Kreuzung oberhalb des oberen Puffers
if (ta.crossover(close, upperBand))
    pendingShort := true

// Schritt 2: Kreuzung unterhalb der 200-Tage-EMA
if (pendingShort and ta.crossunder(close, ema200))
    readyShort := true

// Schritt 3: Kreuzung unterhalb des unteren Puffers
if (readyShort and ta.crossunder(close, lowerBand))
    shortSignalCondition := true
    // Reset der Short-Flags nach Signal
    pendingShort := false
    readyShort := false
    // Reset der Long-Flags, um die Sequenz zu erzwingen
    pendingLong := false
    readyLong := false

// =============================
// Plotten der Signale
// =============================
plotshape(series=longSignalCondition, title="Buy Long", location=location.belowbar, color=color.green, style=shape.labelup, text="Long")
plotshape(series=shortSignalCondition, title="Buy Short", location=location.abovebar, color=color.red, style=shape.labeldown, text="Short")
````
