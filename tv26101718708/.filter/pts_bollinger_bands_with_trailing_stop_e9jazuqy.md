# PTS - Bollinger Bands with Trailing Stop

- url: https://www.tradingview.com/script/E9jaZUQY-PTS-Bollinger-Bands-with-Trailing-Stop/
- type: strategy
- pine_id: PUB;dd39232b44834c1e8b2d24029bdc63bf
- version: 1.0

## Description

[b]PTS - Bollinger Bands with Trailing Stop Strategy[/b]

[b]Overview[/b]

The "PTS - Bollinger Bands with Trailing Stop" strategy is designed to capitalize on strong bullish market movements by combining the Bollinger Bands indicator with a dynamic trailing stop based on the Average True Range (ATR). This strategy aims to enter long positions during upward breakouts and protect profits through an adaptive exit mechanism.

[b]Key Features[/b]

[b]1. Bollinger Bands Indicator[/b]

[list] [b]Basis Moving Average Type:[/b] Choose from SMA, EMA, SMMA, WMA, or VWMA for the Bollinger Bands' basis line. [b]Length:[/b] Adjustable period for calculating the moving average and standard deviation (default is 20). [b]Standard Deviation Multiplier (StdDev):[/b] Determines the width of the bands (default is 2.0). [b]Source:[/b] Select the price data used for calculations (default is the closing price). [/list]

[b]2. Entry Conditions[/b]

[list] [*]The strategy enters a [b]long position[/b] when the [b]closing price[/b] crosses [b]above the upper Bollinger Band[/b], indicating strong upward momentum. [/list]

[b]3. Exit Conditions[/b]

[list] [b]Trailing Stop Loss:[/b] Implemented using ATR to adjust dynamically with market volatility. [b]ATR Length:[/b] Period for calculating ATR (default is 14). [b]ATR Multiplier for Trailing Stop:[/b] Determines how closely the trailing stop follows the price (default is 2.0). [b]Close Below Lower Bollinger Band:[/b] The strategy exits the long position if the closing price crosses [b]below the lower Bollinger Band[/b]. [/list]

[b]4. Risk Management[/b]

[list] [b]Commission and Slippage:[/b] Commission is set at 0.1%; slippage is set to 3. [b]Position Sizing:[/b] Uses 100% of equity per trade (adjustable). [/list]

[b]5. Date Range Filter[/b]

[list] Specify the time period during which the strategy is active. [b]Start Date:[/b] January 1, 2018. [*][b]End Date:[/b] December 31, 2069. [/list]

[b]Customizable Inputs[/b]

[list] [b]BB Length:[/b] Adjust the period for Bollinger Bands calculation. [b]BB StdDev:[/b] Modify the standard deviation multiplier. [b]Basis MA Type:[/b] Select the moving average type. [b]Source:[/b] Choose the price data source. [b]Offset:[/b] Shift the Bollinger Bands on the chart. [b]ATR Length:[/b] Set the period for ATR calculation. [*][b]ATR Multiplier for Trailing Stop:[/b] Adjust the trailing stop sensitivity. [/list]



Thought for 1m 7s

Description for the "PTS - Bollinger Bands with Trailing Stop" Strategy

[b]PTS - Bollinger Bands with Trailing Stop Strategy[/b]

[b]Overview[/b]

The "PTS - Bollinger Bands with Trailing Stop" strategy is designed to capitalize on strong bullish market movements by combining the Bollinger Bands indicator with a dynamic trailing stop based on the Average True Range (ATR). This strategy aims to enter long positions during upward breakouts and protect profits through an adaptive exit mechanism.

[b]Key Features[/b]

[b]1. Bollinger Bands Indicator[/b]

[list] [b]Basis Moving Average Type:[/b] Choose from SMA, EMA, SMMA, WMA, or VWMA for the Bollinger Bands' basis line. [b]Length:[/b] Adjustable period for calculating the moving average and standard deviation (default is 20). [b]Standard Deviation Multiplier (StdDev):[/b] Determines the width of the bands (default is 2.0). [b]Source:[/b] Select the price data used for calculations (default is the closing price). [/list]

[b]2. Entry Conditions[/b]

[list] [*]The strategy enters a [b]long position[/b] when the [b]closing price[/b] crosses [b]above the upper Bollinger Band[/b], indicating strong upward momentum. [/list]

[b]3. Exit Conditions[/b]

[list] [b]Trailing Stop Loss:[/b] Implemented using ATR to adjust dynamically with market volatility. [b]ATR Length:[/b] Period for calculating ATR (default is 14). [b]ATR Multiplier for Trailing Stop:[/b] Determines how closely the trailing stop follows the price (default is 2.0). [b]Close Below Lower Bollinger Band:[/b] The strategy exits the long position if the closing price crosses [b]below the lower Bollinger Band[/b]. [/list]

[b]4. Risk Management[/b]

[list] [b]Commission and Slippage:[/b] Commission is set at 0.1%; slippage is set to 3. [b]Position Sizing:[/b] Uses 100% of equity per trade (adjustable). [/list]

[b]5. Date Range Filter[/b]

[list] Specify the time period during which the strategy is active. [b]Start Date:[/b] January 1, 2018. [*][b]End Date:[/b] December 31, 2069. [/list]

[b]Customizable Inputs[/b]

[list] [b]BB Length:[/b] Adjust the period for Bollinger Bands calculation. [b]BB StdDev:[/b] Modify the standard deviation multiplier. [b]Basis MA Type:[/b] Select the moving average type. [b]Source:[/b] Choose the price data source. [b]Offset:[/b] Shift the Bollinger Bands on the chart. [b]ATR Length:[/b] Set the period for ATR calculation. [*][b]ATR Multiplier for Trailing Stop:[/b] Adjust the trailing stop sensitivity. [/list]

[b]How the Strategy Works[/b]

[b]1. Initialization[/b]

[list] [*]Calculates Bollinger Bands and ATR based on selected parameters. [/list]

[b]2. Entry Logic[/b]

[list] [*]Opens a long position when the closing price exceeds the upper Bollinger Band. [/list]

[b]3. Exit Logic[/b]

[list] Uses a trailing stop loss based on ATR. Exits if the closing price drops below the lower Bollinger Band. [/list]

[b]4. Date Filtering[/b]

[list] [*]Executes trades only within the specified date range. [/list]

[b]Advantages[/b]

[list] [b]Adaptive Risk Management:[/b] Trailing stop adjusts to market volatility. [b]Simplicity:[/b] Clear entry and exit signals. [*][b]Customizable Parameters:[/b] Tailor the strategy to different assets or conditions. [/list]

[b]Considerations[/b]

[list] [b]Aggressive Position Sizing:[/b] Using 100% equity per trade is high-risk. [b]Market Conditions:[/b] Best in trending markets; may produce false signals in sideways markets. [*][b]Backtesting:[/b] Always test on historical data before live trading. [/list]

[b]Disclaimer[/b]

This strategy is intended for educational and informational purposes only. Trading involves significant risk, and past performance is not indicative of future results. Assess your financial situation and consult a financial advisor if necessary.

[b]Usage Instructions[/b]

[list] [b]1. Apply the Strategy:[/b] Add it to your TradingView chart. [b]2. Configure Inputs:[/b] Adjust parameters to suit your style and asset. [b]3. Analyze Backtest Results:[/b] Use the Strategy Tester. [b]4. Optimize Parameters:[/b] Experiment with input values. [*][b]5. Risk Management:[/b] Evaluate position sizing and incorporate risk controls. [/list]

[b]Final Notes[/b]

The "PTS - Bollinger Bands with Trailing Stop" strategy provides a framework to leverage momentum breakouts while managing risk through adaptive trailing stops. Customize and test thoroughly to align with your trading objectives.

## Source Code

````pine
//@version=5
strategy(title="PTS - Bollinger Bands with Trailing Stop", overlay=true, commission_type=strategy.commission.percent, commission_value=0.1, slippage=3, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

length = input.int(20, minval=1, title="BB Length")
mult = input.float(2.0, minval=0.001, maxval=50, title="BB StdDev")
maType = input.string("SMA", "Basis MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
src = input(close, title="Source")
offset = input.int(0, "Offset", minval=-500, maxval=500, display=display.data_window)

startDate = input.time(timestamp("01 Jan 2018 00:00"), "Start Date")
endDate = input.time(timestamp("31 Dec 2069 23:59"), "End Date")

// Bollinger Bands Calculation
ma(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

basis = ma(src, length, maType)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

plot(basis, "Basis", color=#2962FF, offset=offset)
p1 = plot(upper, "Upper", color=#F23645, offset=offset)
p2 = plot(lower, "Lower", color=#089981, offset=offset)
fill(p1, p2, title="Background", color=color.rgb(33, 150, 243, 95))

// ATR for Dynamic Trailing Stop
atrLength = input.int(14, minval=1, title="ATR Length")
atrMultTrail = input.float(2.0, minval=0.1, title="ATR Multiplier for Trailing Stop")
atrValue = ta.atr(atrLength)
trailOffset = atrValue * atrMultTrail

// Entry and Exit Conditions
inDateRange = (time >= startDate) and (time <= endDate)

if inDateRange
    longCondition = (strategy.position_size == 0) and (close > upper)
    exitCondition = (strategy.position_size > 0) and (close < lower)
    
    if longCondition
        strategy.entry("Long", strategy.long)
        // Set Trailing Stop based on ATR
        strategy.exit("Exit Long", "Long", trail_price=close, trail_offset=trailOffset)
    else if exitCondition
        strategy.close("Long")
````
