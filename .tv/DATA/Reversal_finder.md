<!-- tradingview-pine-id: PUB;GZuyxTMfNF8c85RECLMxYpcF3GT2Tjf0 -->
<!-- tradingviewscripts-format: 1 -->
# Reversal finder

Source: https://www.tradingview.com/script/OU82iZCq-Reversal-finder/

## Description

This script is used to visually highlight candles which may signal a reversal following a false break of a support or resistance level.

Inputs are:

[*]Lookback period: look for the highest high and the lowest low of the prior x bars.
[*]SMA length: used for a simple moving average of the range (high minus low) of the prior x bars.
[*]Range multiple: used to filter out signals for any bars with a range smaller than the average range of the preceding bars (determined by SMA length above) e.g. a range multiple of 2 will only show signals for bars with a range twice of that of the average range of the preceding bars.
[*]Range threshold: used to filter signals for bars both the open and close of the bar are at the extreme end of the bar e.g. a threshold setting of 33% will only show buy signals for bars which open and close within the upper 1/3rd of the bar’s high/low range (vice versa for sell signals). This helps highlight, for example, bars with a high which exceeds resistance in a current range but which close back inside the range.
[*]Highlight signal bars?: This will highlight bars with a buy signal in green, sell signal bars in red, and all other bars in grey. The script was designed for use with a dark background, so you will need to play around with the bar colours in the style settings to suit your preferences.

Settings used in the example chart are not the default – they are lookback: 5, SMA length: 20, range multiple: 1.2, range threshold: 33%.

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NS91 2020

//@version=4
study("Reversal finder", overlay=true)

// Inputs

lookback = input(20, "Lookback period for highs and lows")
malen = input(20, "SMA length for candles range")
avrange = sma((high-low), malen)
mult = input(1.5, "Range multiple", type=input.float)
rangethreshold = input(50, "Range threshold (% of candle range)", maxval=99)/100
barcol = input(false, "Highlight signal bars?", type=input.bool)
trackhilo = input(false, "Highlight highest high/lowest low?", type=input.bool)

// Signal conditions

longsig = (high-low)>=(avrange*mult) and ((low<lowest(low[1],lookback))) and (close>=(high-((high-low)*rangethreshold)))
shortsig = (high-low)>=(avrange*mult) and ((high>highest(high[1], lookback))) and (close<=(low+((high-low)*rangethreshold)))

// Plots for highest recent high/lowest recent low

hiplot = trackhilo ? highest(high[1], lookback) : na
loplot = trackhilo ? lowest(low[1],lookback) : na

plot(loplot, title="Lowest low", color=#FF0000, transp=99, trackprice=true) 
plot(hiplot, title="Highest high", color=#00FF03, transp=99, trackprice=true)

// Plots for signal occurrences

plotshape(longsig, title="Long signal", style=shape.labelup, color=color.yellow, transp=1, location=location.belowbar, size=size.tiny)
plotshape(shortsig, title="Short signal", style=shape.labeldown, color=color.yellow, transp=1, location=location.abovebar, size=size.tiny)
plotshape((longsig and close>open), title="Long signal with up candle", style=shape.labelup, color=#00FF03, transp=1, location=location.belowbar, size=size.tiny)
plotshape((shortsig and close<open), title="Short signal with down candle", style=shape.labeldown, color=#FF0000, transp=1, location=location.abovebar, size=size.tiny)

// Bar colours for use with 'highlight signals' option

barcolor(barcol ? barcol and longsig ? #00FF03 : barcol and shortsig ? #FF0000 : #4F4F4F : na)

// Alert conditions

alertcondition(longsig, title="Long signal", message="Reversal finder long signal")
alertcondition(shortsig, title="Short signal", message="Reversal finder short signal")
alertcondition((longsig and close>open), title="Long signal with up candle", message="Reversal finder long signal with up candle")
alertcondition((shortsig and close<open), title="Short signal with down candle", message="Reversal finder short signal with down candle")
alertcondition((longsig or shortsig), title="Long or short signal", message="Reversal finder signal")
````
