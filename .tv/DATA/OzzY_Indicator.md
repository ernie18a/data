<!-- tradingview-pine-id: PUB;5478c013d8644f70b2957cc8440b414c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# OzzY Indicator

Source: https://www.tradingview.com/script/bT9utZF3-OzzY-Indicator/

## Description

Here's a publish-ready description for your OzzY Indicator:

OzzY Indicator

OzzY Indicator is a momentum oscillator based on the classic RSI (Relative Strength Index) formula, relabeled with custom trading zones to help identify potential long and short profit-taking areas.

How it works:
The indicator measures the speed and magnitude of recent price changes on a scale of 0–100, using the same underlying calculation as standard RSI (smoothed average of gains vs. losses over a configurable lookback period).

Key Zones:

🟢 Prof Long (70–100): Price momentum is strong to the upside — often associated with overbought conditions where long positions may be extended.
🔴 Prof Short (0–30): Price momentum is weak / to the downside — often associated with oversold conditions where short positions may be extended.
⚪ Middle Zone (50): Neutral momentum, no clear directional bias.

---

## Source Code

````pine
//@version=6
indicator("OzzY Indicator", shorttitle="OzzY", format=format.price, precision=2)

// Inputs
rsiLength = input.int(14, minval=1, title="Length")
rsiSource = input.source(close, "Source")

longProfLevel = input.int(70, title="Long Prof Level", minval=1, maxval=100)
shortProfLevel = input.int(30, title="Short Prof Level", minval=1, maxval=100)
middleLevel = input.int(50, title="Middle Level", minval=1, maxval=100)

// Calculation (same math as RSI)
change = ta.change(rsiSource)
up = ta.rma(math.max(change, 0), rsiLength)
down = ta.rma(-math.min(change, 0), rsiLength)
ozzyValue = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// Plot
ozzyColor = ozzyValue >= longProfLevel ? color.new(color.green, 0) : ozzyValue <= shortProfLevel ? color.new(color.red, 0) : color.new(#7E57C2, 0)
plot(ozzyValue, "OzzY Indicator", color=ozzyColor, linewidth=2)

// Levels
longProfLine = hline(longProfLevel, "Long Prof", color=color.new(color.green, 0), linestyle=hline.style_dashed)
shortProfLine = hline(shortProfLevel, "Short Prof", color=color.new(color.red, 0), linestyle=hline.style_dashed)
midLine = hline(middleLevel, "Middle", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// Zone fills
fill(longProfLine, midLine, color=color.new(color.green, 90), title="Long Zone")
fill(midLine, shortProfLine, color=color.new(color.red, 90), title="Short Zone")

// Zone labels using label.new, drawn only on the last bar
var label profLongLabel = na
var label profShortLabel = na

if barstate.islast
    label.delete(profLongLabel)
    label.delete(profShortLabel)
    profLongLabel := label.new(bar_index + 5, (longProfLevel + middleLevel) / 2, "Prof Long", xloc=xloc.bar_index, style=label.style_none, textcolor=color.new(color.green, 0), size=size.normal)
    profShortLabel := label.new(bar_index + 5, (middleLevel + shortProfLevel) / 2, "Prof Short", xloc=xloc.bar_index, style=label.style_none, textcolor=color.new(color.red, 0), size=size.normal)

// Optional: highlight overbought/oversold zones
bgcolor(ozzyValue >= longProfLevel ? color.new(color.green, 90) : ozzyValue <= shortProfLevel ? color.new(color.red, 90) : na)
````
