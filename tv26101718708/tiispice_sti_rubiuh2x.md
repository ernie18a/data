# TIISPICE | STI

- url: https://www.tradingview.com/script/RuBiUh2X-TIISPICE-STI/
- type: indicator
- pine_id: PUB;1c5b554a505945b1939854d3136c78ef
- version: 1.0

## Description

[b]TIISPICE | STI — Smart Trend Indicator[/b]
TIISPICE | STI is a clean and responsive trend-following indicator built around the Supertrend algorithm, designed to help traders identify market direction, trend continuation, and potential reversal zones with clarity and minimal chart noise.
Using a combination of ATR (Average True Range) volatility calculations and a customizable multiplier factor, the indicator dynamically adapts to changing market conditions, allowing traders to filter weak price movements and focus on stronger directional trends.

[b]Key Features[/b]
Real-time Supertrend trend detection
Automatic bullish and bearish trend visualization
Dynamic ATR-based market adaptation
Clean chart overlay with minimal distraction
Background trend highlighting for easier trend confirmation
Built-in alert conditions for instant trend reversal notifications

[b]How It Works[/b]
The indicator plots:
A green trend line during bullish market conditions
A red trend line during bearish market conditions
The trend direction is calculated using:
ATR Length → controls market sensitivity
Factor Multiplier → adjusts trend confirmation strength
Higher factor values create smoother, stronger trend confirmations, while lower values react faster to price changes.

[b]Alerts Included[/b]
TIISPICE | STI comes with built-in alerts for:
Bullish trend reversals
Bearish trend reversals
General trend direction changes
This allows traders to stay updated without constantly monitoring charts manually.

[b]Best Used For[/b]
Trend-following strategies
Swing trading
Scalping trend confirmation
Breakout confirmation
Dynamic support and resistance guidance

[b]Recommended Usage[/b]
For best results, combine TIISPICE | STI with:
Market structure analysis
Volume confirmation
Key support and resistance levels
Higher timeframe bias
The indicator works across multiple markets including Forex, Crypto, Indices, and Stocks.

[b]Disclaimer[/b]
TIISPICE | STI is a technical analysis tool and should not be used as standalone financial advice. Proper risk management and trade confirmation are always recommended.

## Source Code

````pine
//@version=6
indicator("TIISPICE | STI", overlay = true, timeframe = "", timeframe_gaps = true)

ATRPERIOD = input.int(10,    "ATR Length", minval = 1)
FACTOR =    input.float(5.0, "Factor",     minval = 0.01, step = 0.01)

[SUPERTREND, direction] = ta.supertrend(FACTOR, ATRPERIOD)

SUPERTREND := barstate.isfirst ? na : SUPERTREND
UPTREND =    plot(direction < 0 ? SUPERTREND : na, "Up Trend",   color = color.green, style = plot.style_linebr)
DOWNTREND =  plot(direction < 0 ? na : SUPERTREND, "Down Trend", color = color.red,   style = plot.style_linebr)
BODYMIDDLE = plot(barstate.isfirst ? na : (open + close) / 2, "Body Middle",display = display.none)

fill(BODYMIDDLE, UPTREND,   title = "Uptrend background",   color = color.new(color.green, 90), fillgaps = false)
fill(BODYMIDDLE, DOWNTREND, title = "Downtrend background", color = color.new(color.red,   90), fillgaps = false)

alertcondition(direction[1] > direction, title='Downtrend to Uptrend', message='The Supertrend value switched from Downtrend to Uptrend ')
alertcondition(direction[1] < direction, title='Uptrend to Downtrend', message='The Supertrend value switched from Uptrend to Downtrend')
alertcondition(direction[1] != direction, title='Trend Change', message='The Supertrend value switched from Uptrend to Downtrend or vice versa')
````
