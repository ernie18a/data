# Coinbase Bitcoin Premium Index

- url: https://www.tradingview.com/script/kqijNHFP-Coinbase-Bitcoin-Premium-Index/
- type: indicator
- pine_id: PUB;fc4025319b1b4e44b9c3eeb0c5514715
- version: 1.0

## Description

Coinbase Bitcoin Premium Index — Simple Explanation

What is it? It simply compares the Bitcoin price on Coinbase (a major U.S. exchange) to the average Bitcoin price across the rest of the world. That difference is the "premium."

How is it calculated? Take the Coinbase price, subtract the global price, divide by the global price. That gives you a percentage that tells you how much higher or lower Coinbase is vs the rest of the world.

What does it mean?

When it's positive (above zero), Bitcoin costs more on Coinbase than elsewhere. This usually means Americans are buying aggressively, big institutions are putting money in, and the mood in the U.S. market is optimistic.

When it's negative (below zero), Bitcoin is cheaper on Coinbase than elsewhere. This usually means Americans are selling, investors are nervous, and money is leaving the market.

Why does it matter? Coinbase is the most regulated and institution-friendly exchange in the U.S. So when this index moves, it often tells you what big U.S. investors and institutions are doing, which tends to move the market.

What happened historically?

During the 2020–2021 bull run the premium stayed positive for a long time, which matched companies like Tesla and MicroStrategy buying massive amounts of Bitcoin.

During the 2022–2023 crash it turned negative often, reflecting fear and heavy selling in the U.S.

Since 2024 traders use it to compare whether Americans or Asians are driving the Bitcoin price on any given day.

Bottom line It's a simple but powerful way to see who is buying or selling Bitcoin and where the pressure is coming from.


Why I added the EMA
The raw premium bounces a lot bar to bar, it's noisy. The EMA smooths it so you can see the trend of the premium, not just the momentary spike. For example if the premium is oscillating around zero but the EMA is slowly rising, that tells you U.S. buying pressure is quietly building even if individual bars look messy.
That said, you're right to question it. For this specific indicator, many traders prefer to read it raw because:

The premium itself is already a derived/smoothed concept
Adding an EMA on top can delay signals
The zero line crossovers are more meaningful than EMA crossovers here

What serious analysts actually use with this indicator:

Divergence — price makes a new high but premium is falling = warning sign
Extended positive streaks — premium stays positive for many consecutive bars = strong institutional accumulation phase
Spike + reversal — a sudden extreme spike followed by quick reversal often precedes a price move
Correlation with funding rates — combining this with perpetual futures funding rates gives a much clearer picture of market positioning
Asian vs U.S. session comparison — checking the premium specifically during U.S. market hours vs Asian hours reveals who is driving price

## Source Code

````pine
//@version=6
indicator("Coinbase Bitcoin Premium Index", shorttitle="CB Premium", overlay=false)

// INPUTS
showMA    = input.bool(true,  "Show EMA Signal Line")
maLength  = input.int(14,     "EMA Length", minval=1)
upperBand = input.float(0.1,  "Upper Threshold (%)", step=0.01)
lowerBand = input.float(-0.1, "Lower Threshold (%)", step=0.01)
showBg    = input.bool(true,  "Show Background Color")

// DATA SOURCES
coinbase  = request.security("COINBASE:BTCUSD",  timeframe.period, close)
globalRef = request.security("BINANCE:BTCUSDT",  timeframe.period, close)

// CALCULATION
premium = (coinbase - globalRef) / globalRef * 100
emaLine = ta.ema(premium, maLength)

// COLORS
colPositive = color.new(color.teal,   0)
colNegative = color.new(color.red,    0)
colEMA      = color.new(color.yellow, 0)
barColor    = premium >= 0 ? colPositive : colNegative
bgColor     = premium >= 0 ? color.new(color.teal, 88) : color.new(color.red, 88)

// BACKGROUND
bgcolor(showBg ? bgColor : na)

// HORIZONTAL LINES
hline(0,    "Zero Line",       color=color.new(color.white, 40), linestyle=hline.style_solid,  linewidth=1)
hline(0.1,  "Upper Threshold", color=color.new(color.teal,  60), linestyle=hline.style_dashed, linewidth=1)
hline(-0.1, "Lower Threshold", color=color.new(color.red,   60), linestyle=hline.style_dashed, linewidth=1)

// PLOTS
plot(premium, title="Premium %", style=plot.style_columns, color=barColor)
plot(showMA ? emaLine : na, title="EMA Signal", color=colEMA, linewidth=2)

// SIGNALS
bullSignal = ta.crossover(premium,  0)
bearSignal = ta.crossunder(premium, 0)

plotshape(bullSignal, title="Turns Positive", location=location.bottom, style=shape.triangleup,   color=colPositive, size=size.tiny)
plotshape(bearSignal, title="Turns Negative", location=location.top,    style=shape.triangledown, color=colNegative, size=size.tiny)

// ALERTS
alertcondition(bullSignal,          title="Premium Turns Positive",   message="Coinbase Premium turned POSITIVE")
alertcondition(bearSignal,          title="Premium Turns Negative",   message="Coinbase Premium turned NEGATIVE")
alertcondition(premium > upperBand, title="Premium Above Upper Band", message="Strong U.S. inflow detected")
alertcondition(premium < lowerBand, title="Premium Below Lower Band", message="Strong U.S. outflow detected")

// INFO TABLE
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    sentiment = premium > upperBand ? "Strong Inflow" : premium > 0 ? "Mild Positive" : premium < lowerBand ? "Strong Outflow" : "Mild Negative"
    table.cell(infoTable, 0, 0, "CB Premium", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(infoTable, 1, 0, str.tostring(math.round(premium, 4)) + "%", text_color=barColor, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(infoTable, 0, 1, "Coinbase",   text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(math.round(coinbase, 2)), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 2, "Global Ref", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(math.round(globalRef, 2)), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 3, "Sentiment",  text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, sentiment,    text_color=color.white, text_size=size.small)
````
