# ADX Breakout Strategy

- url: https://www.tradingview.com/script/B421Qg3h-ADX-Breakout-Strategy/
- type: strategy
- pine_id: PUB;e74f02dd05c2417caed602d68e35d35b
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

The ADX Breakout strategy leverages the Average Directional Index (ADX) to identify and execute breakout trades within specified trading sessions. Designed for the NQ and ES 30-minute charts, this strategy aims to capture significant price movements while managing risk through predefined stop losses and trade limits.

This strategy was taken from a strategy that was posted on YouTube. I would link the video, but I believe is is "against house rules".

█ [b]CONCEPTS[/b]

[list]
[*]The strategy is built upon the following key concepts:
[*]    ADX Indicator: Utilizes the ADX to gauge the strength of a trend. Trades are initiated when the ADX value is below a certain threshold, indicating potential for trend development.
[*]    Trade Session Management: Limits trading to specific hours to align with optimal market activity periods.
[*]    Risk Management: Implements a fixed dollar stop loss and restricts the number of trades per session to control exposure.
[/list]

█ [b]FEATURES[/b]

[list]
[*]    Customizable Stop Loss: Set your preferred stop loss amount to manage risk effectively.
[*]    Trade Session Configuration: Define the trading hours to focus on the most active market periods.
[*]    Entry Conditions: Enter long positions when the price breaks above the highest close in the lookback window and the ADX indicates potential trend strength.
[*]    Trade Limits: Restrict the number of trades per session to maintain disciplined trading.
[*]    Automated Exit: Automatically closes all positions at the end of the trading session to avoid overnight risk.
[/list]

█ [b]HOW TO USE[/b]

[b]Configure Inputs[/b]:
[list]
[*]        Stop Loss ($): Set the maximum loss per trade.
[*]        Trade Session: Define the active trading hours.
[*]        Highest Lookback Window: Specify the number of bars to consider for the highest close.
[/list]

[b]Apply the Strategy[/b]:
[list]
[*]        Add the ADX Breakout strategy to your chart on TradingView.
[*]        Ensure you are using a 30-minute timeframe for optimal performance.
[/list]

█ [b]LIMITATIONS[/b]

[list]
[*] Market Conditions: The strategy is optimized for trending markets and may underperform in sideways or highly volatile conditions.
[*] Timeframe Specific: Designed specifically for 30-minute charts; performance may vary on different timeframes.
[*] Single Asset Focus: Primarily tested on NQ and ES instruments; effectiveness on other symbols is not guaranteed.
[/list]

█ [b]DISCLAIMER[/b]

This ADX Breakout strategy is provided for educational and informational purposes only. It is not financial advice and should not be construed as such. Trading involves significant risk, and you may incur substantial losses. Always perform your own analysis and consider your financial situation before using this or any other trading strategy. The source material for this strategy is publicly available in the comments at the beginning of the code script. This strategy has been published openly for anyone to review and verify its methodology and performance.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HuntGatherTrade
// ========================
// NQ 30 minute, ES 30 minute

//@version=5
strategy("ADX Breakout", overlay=false, initial_capital=25000, default_qty_value=1)

// ===============================
// Input parameters
// ===============================
stopLoss = input(1000.0, title="Stop Loss ($)", group="Exits")
session = input("0730-1430:1234567", group="Trade Session")
highestLB = input(34, title="Highest lookback window", group="Indicator values")

// ===============================
// Trade Session Handling
// ===============================
t = time(timeframe.period, session)

// Reset numTrades at the start of each session
var int numTrades = 0
is_new_session = ta.change(time("D")) != 0
if is_new_session
    numTrades := 0

// ===============================
// Entry Conditions
// ===============================
[plusDI, minusDI, adxValue] = ta.dmi(50, 14)
entryCondition = (close >= ta.highest(close, highestLB)[1]) and (adxValue < 17.5) and (strategy.position_size == 0) and (numTrades < 3) and not na(t)

// ===============================
// 7. Execute Entry
// ===============================
var float stopPricePlot = na

if entryCondition
    entryPrice = close + syminfo.mintick
    strategy.entry("Long Entry", strategy.long, stop=entryPrice)
    //stopPrice = strategy.position_avg_price - (stopLoss / syminfo.pointvalue)
    //strategy.exit("Stop Loss", "Long Entry", stop=stopPrice)
    numTrades += 1

if (strategy.position_size > 0) and (strategy.position_size[1] == 0)
    stopPoints = stopLoss / syminfo.pointvalue
    stopPrice = strategy.position_avg_price - stopPoints
    stopPrice := math.round(stopPrice / syminfo.mintick) * syminfo.mintick
    strategy.exit("Stop Loss", from_entry="Long Entry", stop=stopPrice)


if ta.change(strategy.opentrades) == 1
    float entryPrice = strategy.opentrades.entry_price(0)
    stopPricePlot := entryPrice - (stopLoss / syminfo.pointvalue)

if ta.change(strategy.closedtrades) == 1
    stopPricePlot   := na

plot(stopPricePlot, "Stop-loss level", color.red, 1, plot.style_linebr)

// ===============================
// Exit at End of Session
// ===============================
if na(t) and strategy.position_size != 0
    strategy.close_all(comment="End of Day Exit")
````
