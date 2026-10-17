# LinReg Scale-In Strategy

- url: https://www.tradingview.com/script/dpkq3n4O/
- type: strategy
- pine_id: PUB;8b490dde7d28461fbd1522fca9c5ed50
- version: 1.0

## Description

This strategy is based on an basic LinReg concept. Instead of using traditional price levels or moving averages, it uses the Linear Regression Correlation Coefficient (Pearson's r) to measure the actual strength of a trend and dynamically build up a position.

How it works:
The indicator calculates how closely the price follows a linear trend, returning a value between -1 and +1.

    Scale-In (Entries): The strategy enters a Long position step-by-step as the uptrend gains momentum. It adds to the position when the coefficient crosses above the 0.25, 0.50, and 0.75 thresholds (pyramiding up to 3 times).

    Scale-Out (Exit): Following the "let profits run but cut losses quick" mentality, the strategy closes the entire position as soon as the trend starts dying out and the coefficient crosses back down below 0.25.

Setup Tip: It is recommended using this approach on commodities using the Daily timeframe. The strategy is set to fixed contracts by default to allow smooth backtesting on futures like NQ or ES without running into margin limits.

Disclaimer:
This script is published for educational and testing purposes only. It does not constitute financial advice. Trading futures and other financial instruments involves significant risk of loss. Past performance is not indicative of future results. Always do your own research and backtesting before risking real capital.

## Source Code

````pine
//@version=5
strategy("LinReg Scale-In Strategy", overlay=false, pyramiding=3, initial_capital=100000, default_qty_type=strategy.fixed, default_qty_value=1)

// --- INPUTS ---
length = input.int(20, title="Lookback Period", minval=5)

// --- BERECHNUNG ---
coeff = ta.correlation(close, bar_index, length)

// --- VISUALISIERUNG ---
plot(coeff, color=color.blue, title="LinReg Coefficient", linewidth=2)
hline(0.75, "Level 0.75 (Strong Trend)", color=color.green, linestyle=hline.style_dashed)
hline(0.50, "Level 0.50 (Medium Trend)", color=color.yellow, linestyle=hline.style_dashed)
hline(0.25, "Level 0.25 (Weak Trend)", color=color.orange, linestyle=hline.style_dashed)
hline(0.00, "Zero Line", color=color.gray, linestyle=hline.style_solid)

// --- LOGIK & SIGNALE ---
cross_up_25 = ta.crossover(coeff, 0.25)
cross_up_50 = ta.crossover(coeff, 0.50)
cross_up_75 = ta.crossover(coeff, 0.75)
cross_down_25 = ta.crossunder(coeff, 0.25)

// --- HANDELSAUSFÜHRUNG ---
// Jetzt kauft er jeweils exakt 1 Kontrakt pro Stufe
if (cross_up_25)
    strategy.entry("Long @ 0.25", strategy.long)

if (cross_up_50)
    strategy.entry("Long @ 0.50", strategy.long)

if (cross_up_75)
    strategy.entry("Long @ 0.75", strategy.long)

// Exit, wenn der Trend stirbt
if (cross_down_25)
    strategy.close_all(comment="Exit < 0.25")
````
