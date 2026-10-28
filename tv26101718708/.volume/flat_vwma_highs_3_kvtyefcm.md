# Flat VWMA Highs 3

- url: https://www.tradingview.com/script/KVTyEFcM-Flat-VWMA-Highs-3/
- type: indicator
- pine_id: PUB;d7ce85f7d2a5441aa11dac71476fee32
- version: 1.0

## Description

The Flat VWMA High3 is a short-term resistance detection indicator based on the Volume-Weighted Moving Average (VWMA) applied to the high prices of candles. By default, it uses a length of 3, averaging the last three highs while weighting them according to traded volume.

Because higher-volume candles have a greater influence on the calculation, the indicator is designed to highlight areas where significant selling pressure or price rejection may be occurring. When the VWMA of highs becomes nearly horizontal, the script projects a short blue resistance segment into future bars, helping traders identify potential overhead supply zones.

[b]Usage[/b]

The indicator is intended to be used similarly to traditional support and resistance analysis:

[list]
[*]Bullish Signal: Price breaks and closes above a resistance segment, suggesting supply may have been absorbed.
[*]Bearish / Resistance Holding: Price rejects from the segment, indicating sellers may still be defending that area.
[*]
[/list][b]

The indicator works particularly well for:[/b]

Identifying repeated upper wick rejection areas
[list]
[*]Detecting short-term supply zones
[*]Visualizing potential institutional resistance levels
[*]Combining with gap analysis, moving averages, or volume studies
[/list]
Optional Features
[list=1]
[*]VWMA Length
Default: 3
[*]Increase the length to identify broader or smoother resistance areas.
[*]Flatness Threshold (%)
Default: 0.15%
[*]Controls how “flat” the VWMA must be before a resistance segment is drawn. Higher-volatility stocks may require a larger threshold.
[*]Extend Segment Right Bars
Default: 5
[*]Controls how far the resistance segment projects into future bars.
[*]Show VWMA High
[*]Displays the underlying VWMA(high) line directly on the chart for additional visualization.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SpreadEagle71

//@version=6
indicator("Flat VWMA Highs 3",shorttitle = "Flat H3", overlay=true, max_lines_count=500)

// === Inputs ===
vwmaLen      = input.int(3, "VWMA High Length", minval=1)
flatPercent  = input.float(0.15, "Flatness Threshold %", step=0.01)
extendBars   = input.int(5, "Extend Segment Right Bars", minval=1, maxval=50)
showVWMA     = input.bool(false, "Show VWMA High")

// === VWMA of Highs ===
vwmaHigh = ta.vwma(high, vwmaLen)

// === Flatness Condition ===
pctDiff = math.abs(vwmaHigh - vwmaHigh[1]) / vwmaHigh * 100
isFlat = pctDiff <= flatPercent

// Trigger only when a new flat area begins
newFlat = isFlat and not isFlat[1]

// === Draw short segment only, no connection ===
if newFlat
    line.new(
         bar_index,
         vwmaHigh,
         bar_index + extendBars,
         vwmaHigh,
         color=color.blue,
         width=3
     )

// Optional normal VWMA plot
plot(showVWMA ? vwmaHigh : na, "VWMA High", color=color.orange)
````
