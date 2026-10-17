# SMAST Oscillator [point algo]

- url: https://www.tradingview.com/script/dNLVZ4Jb-SMAST-Oscillator-point-algo/
- type: indicator
- pine_id: PUB;4fefc9619e7a4b83904b574285e02984
- version: 1.0

## Description

The SMAST Oscillator combines a Simple Moving Average (SMA) with the Supertrend indicator to measure the distance between them as a momentum oscillator.

Instead of displaying the SMA and Supertrend directly on the price chart, this indicator plots the difference between the two values around a zero line, making it easier to identify trend strength, momentum shifts, and potential reversals.

[b]How it works[/b]
The oscillator is calculated as:
Oscillator = SMA − Supertrend
Positive values indicate the SMA is above the Supertrend.
Negative values indicate the SMA is below the Supertrend.
The farther the oscillator moves away from zero, the greater the separation between the two indicators.

The histogram-style fill changes color automatically based on whether the oscillator is above or below the zero line.


Interpretation
Bullish Momentum
[list]
[*]Oscillator is above zero.
[*]Green color.
[*]SMA is positioned above the Supertrend.
[*]Suggests bullish market structure.
[/list]
Bearish Momentum
[list]
[*]Oscillator is below zero.
[*]Red color.
[*]SMA is positioned below the Supertrend.
[*]Suggests bearish market structure.
[/list]

Zero Line Cross

A cross above or below zero may indicate that the relationship between the SMA and Supertrend has changed.

Many traders use these transitions as an additional confirmation alongside their existing trading strategy.

[b]Inputs[/b]

SMA Length
[list]
[*]Period used for the Simple Moving Average.
[/list]
Supertrend ATR Length
[list]
[*]ATR period used in the Supertrend calculation.
[/list]

Supertrend Multiplier
[list]
[*]Controls the sensitivity of the Supertrend.
[*]Lower values react faster.
[*]Higher values reduce noise but react more slowly.
[/list]

Best Use Cases
[list]
[*]Trend confirmation
[*]Momentum analysis
[*]Identifying trend transitions
[*]Multi-timeframe confirmation
[*]Swing trading
[*]Intraday trend filtering
[/list]

[b]Notes[/b]
[list]
[*]This indicator is based on the built-in TradingView Supertrend function.
[*]It is designed as a momentum and trend-strength visualization.
[*]It should not be used as a standalone buy or sell signal.
[*]Consider combining it with price action, volume analysis, support/resistance, or other confirmation tools.
[/list]

[b]Disclaimer[/b]
This script is provided for educational and analytical purposes only. It does not constitute financial or investment advice. Always perform your own analysis and manage risk appropriately before making trading decisions.

## Source Code

````pine
//@version=6
indicator("SMAST Oscillator [point algo]", shorttitle="MAST Oscillator", overlay=false)

sma_len = input.int(9, title="SMA Length")
st_atr_len = input.int(10, title="Supertrend ATR Length")
st_factor = input.float(3.0, title="Supertrend Multiplier")
sma_val = ta.sma(close, sma_len)
[st_val, st_dir] = ta.supertrend(st_factor, st_atr_len)
osc_val = sma_val - st_val
line_color = osc_val >= 0 ? #00E676 : #FF1744
fill_color = osc_val >= 0 ? color.new(#00E676, 80) : color.new(#FF1744, 80)
hline(0, title="Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
p_zero = plot(0, title="Zero Baseline", display=display.none)
p_osc = plot(osc_val, title="Oscillator", color=line_color, linewidth=2)
fill(p_osc, p_zero, color=fill_color, title="Oscillator Fill")
````
