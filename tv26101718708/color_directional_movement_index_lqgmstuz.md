# Color Directional Movement Index

- url: https://www.tradingview.com/script/lqgMStUZ-Color-Directional-Movement-Index/
- type: indicator
- pine_id: PUB;d26451eec2044d88916fea4a7d301a63
- version: 1.0

## Description

This Indicator gives Color to the ADX line. If +DI > -DI the color will be green else Red. WE can this instantly identify the direction of the trend.

## Source Code

````pine
//@version=6
indicator(title="Colour Directional Movement Index", shorttitle="DMI", format=format.price, precision=4, timeframe="", timeframe_gaps=true)

TT_ADX_LEN = "The time period to be used in calculating the ADX which has a smoothing component."
TT_DI_LEN  = "The time period to be used in calculating the DI (Directional Indicator)."

lensig = input.int(14, "ADX Smoothing", minval = 1, tooltip = TT_ADX_LEN)
len =    input.int(14, "DI Length",     minval = 1, tooltip = TT_DI_LEN)

up = ta.change(high)
down = -ta.change(low)
plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
trur = ta.rma(ta.tr, len)
plus = fixnan(100 * ta.rma(plusDM, len) / trur)
minus = fixnan(100 * ta.rma(minusDM, len) / trur)
sum = plus + minus
adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), lensig)

// Conditional coloring logic for the ADX line
adxColor = if adx > 25 and plus > minus
    color.green
else if adx > 25 and minus > plus
    color.red
else
    color.gray

// Plotting outputs (ADX line width is increased slightly to make color changes highly visible)
plot(adx, color=adxColor, title="ADX", linewidth=2)
plot(plus, color=#2962FF, title="+DI")
plot(minus, color=#FF6D00, title="-DI")

// Visual anchor line for the 25 level threshold
hline(25, "Trend Threshold", color=color.new(color.white, 50), linestyle=hline.style_dashed)
````
