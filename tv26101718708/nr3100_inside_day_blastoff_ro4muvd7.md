# NR3-100 / Inside Day / BlastOff

- url: https://www.tradingview.com/script/rO4muVD7-NR3-100-Inside-Day-BlastOff/
- type: indicator
- pine_id: PUB;34a1350ddace41e4b71a4089fc4d94fc
- version: 1.0

## Description

Want to identify market compression phases before price transitions into an explosive move? This indicator combines several classic signs of volatility contraction and pre-expansion behavior, helping you quickly spot potentially important trading days before strong directional movement begins.

"NR3-100 / Inside Day / BlastOff" analyzes the current price range and determines how narrow it is relative to previous bars. The indicator automatically detects Narrow Range sequences from NR3 up to NR100. The higher the NR value, the longer the current bar has remained the narrowest compared with preceding bars.

Narrow Range conditions are displayed as a histogram. For example, NR7 means that the current bar’s range is less than or equal to the range of each of the previous six bars. These conditions make it easy to visually identify periods of significant volatility compression.

The indicator also detects "Inside Day" conditions, where the current bar’s entire range is contained within the previous bar’s range. Inside Days are marked with a separate green marker and can be used as an additional sign of market consolidation.

The third component is "Larry Williams BlastOff". The indicator identifies conditions where the candle body occupies less than 20% of the bar’s total range. Larry Williams used this concept to identify bars that may precede an expansion in market volatility. BlastOff conditions are marked with a separate orange upward arrow below the zero line.

This allows you to monitor three types of pre-expansion conditions in a single indicator panel:

- Narrow Range — measures the degree of current range compression.
- Inside Day — identifies bars fully contained within the previous bar.
- BlastOff — highlights conditions associated with potential upcoming volatility expansion.

The most interesting situations may occur when several signals appear simultaneously or close together. For example, a high NR value combined with an Inside Day and BlastOff may indicate an especially pronounced compression phase.

The indicator does not attempt to predict the direction of the next move. Its purpose is to identify market conditions that may precede volatility expansion.

Use "NR3-100 / Inside Day / BlastOff" to quickly locate periods of maximum market compression and focus your attention on areas where the next explosive market move may be developing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smollet
//@version=6

indicator("NR3-100 / Inside Day / BlastOff", overlay=false, max_bars_back=100)

// Current bar range
barRange = high - low

// Maximum Narrow Range value for the current bar
int nrValue = 0
int matchedBars = 1

// NRn means:
// The current bar range <= the range of each of the previous n-1 bars.
for i = 1 to 99
    if na(barRange[i])
        break
    if barRange <= barRange[i]
        matchedBars := i + 1
    else
        break

// Show only NR3 and higher
nrValue := matchedBars >= 3 ? matchedBars : 0

// Histogram
plot(nrValue >= 3 ? nrValue : na, title="Narrow Range", color=color.aqua, style=plot.style_columns, linewidth=2)

// Lower boundary of the displayed NR range
hline(3, "NR3", linestyle=hline.style_dotted)

// Inside Day condition
insideDay = high < high[1] and low > low[1]

// Display Inside Day marker above the NR histogram, or at level 3 if the bar is not NR
plotshape(insideDay ? (nrValue >= 3 ? nrValue + 6 : 3) : na, title="Inside Day", style=shape.circle, location=location.absolute, size=size.small, color=color.lime)

// Larry Williams BlastOff
blastOff = barRange > 0.0 ? math.abs(close - open) / barRange : na
blastOffSignal = blastOff < 0.20

// BlastOff < 20% marker below zero
plotshape(blastOffSignal ? -2.0 : na, title="BlastOff < 20%", style=shape.labelup, location=location.absolute, size=size.small, color=color.orange)
````
