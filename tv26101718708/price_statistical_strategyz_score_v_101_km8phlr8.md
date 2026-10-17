# Price Statistical Strategy-Z Score V 1.01

- url: https://www.tradingview.com/script/km8PhlR8-Price-Statistical-Strategy-Z-Score-V-1-01/
- type: strategy
- pine_id: PUB;8e3cf618b18e493da6f03191d61716d6
- version: 1.0

## Description

[b]Price Statistical Strategy – Z Score V 1.01[/b]

[b]Overview
[/b]
A technical breakdown of the logic and components of the “Price Statistical Strategy – Z Score V 1.01”.
This script implements a smoothed Z-Score crossover mechanism applied to the closing price to detect potential statistical deviations from local price mean. The strategy operates solely on price data (close) and includes signal spacing control and momentum-based candle filters. No volume-based or trend-detection components are included.


[b]Core Methodology
[/b]
The strategy is built on the statistical concept of Z-Score, which quantifies how far a value (closing price) is from its recent average, normalized by standard deviation. Two moving averages of the raw Z-Score are calculated: a short-term and a long-term smoothed version. The crossover between them generates long entries and exits.


[b]Signal Conditions
[/b]
Entry Condition:
A long position is opened when the short-term smoothed Z-Score crosses above the long-term smoothed Z-Score, and additional entry conditions are met.

Exit Condition:
The position is closed when the short-term Z-Score crosses below the long-term Z-Score, provided the exit conditions allow.

Signal Gapping:
A minimum number of bars (Bars gap between identical signals) must pass between repeated entry or exit signals to reduce noise.

Momentum Filter:
Entries are prevented during sequences of three or more consecutively bullish candles, and exits are prevented during three or more consecutively bearish candles.

[b] Z-Score Function
The Z-Score is calculated as:[/b]

Z = (Close - SMA(Close, N)) / STDEV(Close, N)

Where N is the base period selected by the user.

[b]Input Parameters
[/b]

[i]Enable Smoothed Z-Score Strategy
[/i]Enables or disables the Z-Score strategy logic. When disabled, no trades are executed.

[i]Z-Score Base Period
[/i]Defines the number of bars used to calculate the simple moving average and standard deviation for the Z-Score. This value affects how responsive the raw Z-Score is to price changes.

[i]Short-Term Smoothing
[/i]Sets the smoothing window for the short-term Z-Score. Higher values produce smoother short-term signals, reducing sensitivity to short-term volatility.

[i]Long-Term Smoothing
[/i]Sets the smoothing window for the long-term Z-Score, which acts as the reference line in the crossover logic.

[i]Bars gap between identical signals
[/i]Minimum number of bars that must pass before another signal of the same type (entry or exit) is allowed. This helps reduce redundant or overly frequent signals.

[b]Trade Visualization Table
[/b]
A table positioned at the bottom-right displays live PnL for open trades:

Entry Price

Unrealized PnL %
Text colors adapt based on whether unrealized profit is positive, negative, or neutral.

[b] Technical Notes
[/b]
This strategy uses only close prices — no trend indicators or volume components are applied.

All calculations are based on simple moving averages and standard deviation over user-defined windows.

Designed as a minimal, isolated Z-Score engine without confirmation filters or multi-factor triggers.

## Source Code

````pine
//@version=6
strategy("Price Statistical Strategy-Z Score V 1.01", overlay=true)

// === Enable / Disable Z-Score Strategy Block ===
enableZScore = input.bool(true, title="Enable Smoothed Z-Score Strategy", tooltip="When enabled, this block calculates a smoothed Z-Score of the closing price and generates entry/exit signals based on crossover behavior between short-term and long-term smoothed Z-Scores.\n\nRecommended for quick and classic detection of price deviation from mean.\nSensitive to outliers. Best suited for relatively normal-distributed market conditions.")

// === Z-Score Parameters ===
zBaseLength = input.int(3, minval=1, title="Z-Score Base Period")
shortSmooth = input.int(3, title="Short-Term Smoothing")
longSmooth = input.int(5, title="Long-Term Smoothing")

// === Z-Score Calculation Function ===
f_zscore(src, length) =>
    mean = ta.sma(src, length)
    std_dev = ta.stdev(src, length)
    z = (src - mean) / std_dev
    z

// === Z-Score Logic ===
zRaw = f_zscore(close, zBaseLength)
zShort = ta.sma(zRaw, shortSmooth)
zLong = ta.sma(zRaw, longSmooth)


// === Minimum gap between identical signals ===
gapBars = input.int(5, minval=1, title="Bars gap between identical signals", tooltip="Minimum number of bars required between two identical signals (entry or exit). Helps reduce signal noise.")


// === Candle-based momentum filters ===
bullish_3bars = close > close[1] and close[1] > close[2] and close[2] > close[3] and close[3] > close[4]
bearish_3bars = close < close[1] and close[1] < close[2] and close[2] < close[3] and close[3] < close[4]

// === Entry and Exit Logic with minimum signal gap and candle momentum filter ===
var int lastEntryBar = na
var int lastExitBar  = na

if enableZScore
    longCondition = (zShort > zLong)
    exitCondition = (zShort < zLong)

    if longCondition and (na(lastEntryBar) or bar_index - lastEntryBar > gapBars) and not bullish_3bars
        strategy.entry("Z Score", strategy.long)
        lastEntryBar := bar_index

    if exitCondition and (na(lastExitBar) or bar_index - lastExitBar > gapBars) and not bearish_3bars
        strategy.close("Z Score", comment="Z Score")
        lastExitBar := bar_index

// === Real-time PnL Table for Last Open Position ===
var table positionTable = table.new(position.bottom_right, 2, 2, border_width=1)

// Header Labels
table.cell(positionTable, 0, 0, "Entry Price", text_color=color.white, bgcolor=color.gray)
table.cell(positionTable, 1, 0, "Unrealized PnL (%)", text_color=color.white, bgcolor=color.gray)

// Values (only when position is open)
isLong        = strategy.position_size > 0
entryPrice    = strategy.position_avg_price
unrealizedPnL = isLong ? (close - entryPrice) / entryPrice * 100 : na

// Define dynamic text color for PnL
pnlColor = unrealizedPnL > 0 ? color.green : unrealizedPnL < 0 ? color.red : color.gray

// Update Table Content
if isLong
    table.cell(positionTable, 0, 1, str.tostring(entryPrice, "#.####"), text_color=color.gray, bgcolor=color.new(color.gray, 90))
    table.cell(positionTable, 1, 1, str.tostring(unrealizedPnL, "#.##") + " %", text_color=pnlColor, bgcolor=color.new(pnlColor, 90))
else
    table.cell(positionTable, 0, 1, "—", text_color=color.gray, bgcolor=color.new(color.gray, 90))
    table.cell(positionTable, 1, 1, "—", text_color=color.gray, bgcolor=color.new(color.gray, 90))
````
