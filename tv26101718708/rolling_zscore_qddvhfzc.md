# Rolling Z-Score

- url: https://www.tradingview.com/script/Qddvhfzc-Rolling-Z-Score/
- type: indicator
- pine_id: PUB;b23241bbb0864c7f98d8b1d9a0fa12d2
- version: 1.0

## Description

A simple statistical indicator that measures how far the current price is from its recent average, expressed in standard deviations (a "z-score"). It helps visualize when price is unusually stretched relative to its own recent behavior.

What it does
This indicator calculates a rolling z-score of price over a user-defined lookback window. The z-score expresses the current value as the number of standard deviations away from its rolling mean:
z = (price − rolling mean) / rolling standard deviation
A reading of 0 means price is exactly at its recent average. +2 means two standard deviations above average; −2 means two below. Values reset continuously as the rolling window moves.
How to read it

Near 0 → price is close to its recent mean
Above +2 → price is statistically stretched to the upside
Below −2 → price is statistically stretched to the downside

The dashed lines mark the ±2 reference levels; the center line marks the mean.
Inputs

Window length: the lookback period for the mean and standard deviation (default 20)
Source: the price series used (default close)

Important notes
A high or low z-score is not a buy or sell signal on its own. In a trending market, price can stay stretched (high or low z-score) for extended periods — an extreme reading can keep getting more extreme. This tool measures statistical deviation; it does not predict reversals. Use it as one input within a broader, tested framework, not as a standalone signal.

## Source Code

````pine
//@version=6
indicator("Rolling Z-Score", overlay=false)
length = input.int(20, "Window")
mean = ta.sma(close, length)
std = ta.stdev(close, length)
zscore = (close - mean) / std
plot(zscore)
hline(2, "Upper", color=color.red)
hline(-2, "Lower", color=color.green)
hline(0, "Mean", color=color.gray)
````
