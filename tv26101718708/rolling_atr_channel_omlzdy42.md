# Rolling ATR Channel

- url: https://www.tradingview.com/script/OmLZdY42-Rolling-ATR-Channel/
- type: indicator
- pine_id: PUB;ec66d2dd5b22412a8775290a767db0e6
- version: 1.0

## Description

The Rolling ATR Channel is a volatility and trend-following indicator designed to identify breakout opportunities while filtering lower-quality counter-trend signals. It combines ATR-based dynamic price channels, a Rolling Donchian Cloud, and a moving average direction filter to improve trade clarity and market structure awareness.

This tool is built to help traders identify:

Trend continuation opportunities
Breakout confirmations
Volatility expansion zones
Directional bias
High-probability trend-aligned entries
Core Features
1) ATR Dynamic Channel

The main channel is built using a Simple Moving Average (SMA) as the centreline, with upper and lower bands expanded using Average True Range (ATR).

This allows the channel to automatically adapt to market volatility:

High volatility = wider channel
Low volatility = tighter channel

This makes it useful across trending and consolidating conditions.

2) Buy & Sell Signal Detection

Signals are generated when price breaks beyond the ATR channel:

Buy Signal

Triggered when price crosses above the upper ATR channel

Sell Signal

Triggered when price crosses below the lower ATR channel

These are designed to highlight potential momentum continuation or breakout setups.

3) MA Direction Filter (Optional)

A built-in trend filter improves signal quality by aligning trades with moving average direction.

When enabled:

If the moving average is sloping upward → only Buy signals are shown
If the moving average is sloping downward → only Sell signals are shown
Counter-trend signals are blocked

This helps reduce false entries during strong directional markets.

Can be turned ON/OFF in settings.

4) Rolling Donchian Cloud

A Donchian-based volatility cloud is included for additional market structure context.

It plots:

Rolling highest highs
Rolling lowest lows

Useful for:

Breakout confirmation
Range boundaries
Trend strength analysis
Market compression/expansion zones
5) Sensitivity Toggle

The Sensitivity Mode adjusts how the ATR channel behaves.

This allows traders to switch between:

More responsive channel behaviour
Broader volatility-based expansion

Helpful for adapting to scalping, intraday, or swing trading conditions.

Best Used For
Trend-following strategies
Breakout trading
Momentum continuation setups
Market structure analysis
Volatility-based trading systems
Crypto
Forex
Indices
Stocks
Commodities
How to Read It

Green Buy Label = Price breakout above upper ATR band
Red Sell Label = Price breakout below lower ATR band
Green/Red ATR Channel = Dynamic volatility envelope
Purple Donchian Cloud = High/low rolling breakout zone
MA Direction Filter = Trend alignment confirmation

Recommended Use

This indicator works best when combined with:

Higher timeframe trend confirmation
Support / resistance
Volume confirmation
Liquidity sweeps
Market structure breaks
Risk management rules

It should not be used as standalone financial advice or as a guaranteed entry system.

Summary

Rolling ATR Channel by Mrs Norris Meme is a clean hybrid trend + volatility breakout indicator built for traders who want stronger directional filtering, adaptive ATR channels, and clearer breakout visualisation while reducing unnecessary counter-trend noise.

Designed to keep signal quality high while staying visually simple and practical.

## Source Code

````pine
//@version=6
indicator('Rolling ATR Channel', overlay = true)

//====================================================
// INPUTS
//====================================================
length = input.int(14, title = 'ATR Length')
mult = input.float(0.5, title = 'ATR Multiplier')
elasticity = input.float(1.0, title = 'Signal Elasticity', minval = 0.1, step = 0.1)
sensitivity = input.bool(true, title = 'Sensitivity Toggle')

// NEW FILTER TOGGLE
useMADirectionFilter = input.bool(true, title = 'Use MA Direction Filter')

//====================================================
// CORE CALCULATIONS
//====================================================
atrValue = ta.atr(length)

// Main SMA (channel basis)
basisMA = ta.sma(close, length)

// ATR Channel
upperChannel = basisMA + atrValue * mult * elasticity
lowerChannel = basisMA - atrValue * mult * elasticity

// Sensitivity mode
if sensitivity
    upperChannel := basisMA + atrValue * mult
    lowerChannel := basisMA - atrValue * mult
    lowerChannel

//====================================================
// PLOTS
//====================================================
plot(upperChannel, title = 'Upper Channel', color = color.new(color.green, 0), linewidth = 1)
plot(lowerChannel, title = 'Lower Channel', color = color.new(color.red, 0), linewidth = 1)

// Channel fill
fill(plot(upperChannel), plot(lowerChannel), color = color.rgb(13, 246, 40, 48), title = 'Channel Fill')

//====================================================
// DONCHIAN CLOUD
//====================================================
donchianUpper = ta.highest(high, length)
donchianLower = ta.lowest(low, length)

plot(donchianUpper, title = 'Donchian Upper', color = color.new(color.green, 0), linewidth = 2, style = plot.style_stepline)

plot(donchianLower, title = 'Donchian Lower', color = color.new(color.red, 0), linewidth = 2, style = plot.style_stepline)

fill(plot(donchianUpper), plot(donchianLower), color = color.rgb(238, 8, 250, 74), title = 'Donchian Cloud Fill')

//====================================================
// MA DIRECTION FILTER
//====================================================
maUp = basisMA > basisMA[1]
maDown = basisMA < basisMA[1]

//====================================================
// SIGNALS
//====================================================
rawBuySignal = ta.crossover(close, upperChannel)
rawSellSignal = ta.crossunder(close, lowerChannel)

// Filter logic
buySignal = rawBuySignal and (not useMADirectionFilter or maUp)
sellSignal = rawSellSignal and (not useMADirectionFilter or maDown)

//====================================================
// PLOT SIGNALS
//====================================================
plotshape(series = buySignal, location = location.belowbar, color = color.new(color.green, 0), style = shape.labelup, text = 'BuLL', title = 'Buy Signal')

plotshape(series = sellSignal, location = location.abovebar, color = color.new(color.red, 0), style = shape.labeldown, text = 'BEAR', title = 'Sell Signal')

//====================================================
// TOOLTIP LABEL
//====================================================
var label tooltipLabel = na

if na(tooltipLabel)
    tooltipLabel := label.new(x = bar_index, y = na, text = '', xloc = xloc.bar_index, yloc = yloc.price, color = color.rgb(144, 0, 255, 39), textcolor = color.black, size = size.small, style = label.style_label_down)
    tooltipLabel

var string tooltipText = ''

tooltipText := 'Rolling ATR Channel by Mrs Norris Meme\n' + 'Upper Channel: ' + str.tostring(upperChannel, format.mintick) + '\n' + 'Lower Channel: ' + str.tostring(lowerChannel, format.mintick) + '\n' + 'ATR Value: ' + str.tostring(atrValue, format.mintick) + '\n' + 'MA Trend: ' + (maUp ? 'Up' : maDown ? 'Down' : 'Flat') + '\n' + 'Donchian Upper: ' + str.tostring(donchianUpper, format.mintick) + '\n' + 'Donchian Lower: ' + str.tostring(donchianLower, format.mintick)

label.set_text(tooltipLabel, tooltipText)
````
