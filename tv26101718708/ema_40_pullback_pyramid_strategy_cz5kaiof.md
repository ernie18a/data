# EMA 40 Pullback Pyramid Strategy

- url: https://www.tradingview.com/script/cz5KaioF-EMA-40-Pullback-Pyramid-Strategy/
- type: strategy
- pine_id: PUB;7afd09b42e734bf8b173975c0bd81aa0
- version: 1.0

## Description

EMA 40 Pullback Pyramid Strategy

EMA 40 Pullback Pyramid Strategy is an educational trend-following strategy designed to study long-side entries around a rising 40-period Exponential Moving Average, with optional pullback re-entry logic, ADX trend-strength filtering, and EMA cross-based entry/exit conditions.

This is a strategy script, not a prediction tool and not financial advice. It is intended for research, backtesting, and forward-testing only. Historical results are hypothetical and can differ significantly from live trading due to slippage, commissions, liquidity, order execution, symbol behavior, timeframe selection, and market regime changes.

What the strategy does

The strategy uses the 40-period EMA as its main directional reference.

The EMA color changes according to its slope:

- Green EMA: the EMA is rising.
- Red EMA: the EMA is falling.
- Gray EMA: the EMA is flat or unchanged.

The strategy can enter long positions when selected bullish conditions occur and can close positions when selected bearish or exit conditions occur.

Core logic

1. EMA 40 trend direction

The strategy calculates a fast EMA using the selected EMA length. The default value is 40.

A bullish trend condition exists when the EMA is rising. A bearish condition exists when the EMA is falling.

The original base entry occurs when the EMA changes from not rising to rising, and ADX is above the selected minimum threshold.

2. ADX trend-strength filter

The strategy uses DMI / ADX to filter weak trend conditions.

A trade can qualify only when ADX is above the selected ADX threshold. The default threshold is 20.

This filter is intended to reduce entries during weak or sideways market conditions, but it does not eliminate false signals.

3. Pullback re-entry logic

When enabled, the pullback module looks for price to retrace toward the EMA by a selected ATR-based distance and then recover above the EMA.

The pullback condition uses:

- ATR length.
- Pullback distance multiplied by ATR.
- Recovery candle logic, where the candle closes above the EMA and closes above its open.

This feature is designed to study additional entries during an existing upward EMA trend. Because pyramiding is enabled, these pullback signals can add to an existing long position depending on the strategy settings.

4. EMA 40 cross signals

The strategy includes optional EMA cross buy/sell logic.

The cross detection mode can be:

- Close mode: uses close crossing above or below the EMA.
- Wick mode: uses wick interaction with the EMA followed by a close on the opposite side.

When “Use EMA cross signals in strategy orders” is enabled, these signals can participate in actual strategy entries and exits. When disabled, they can be used only as visual reference signals.

5. Minimum bars between entries

The strategy includes a minimum-bars-between-entries setting. This helps reduce immediate repeated entries and gives users control over signal spacing.

6. Pyramiding

The strategy uses pyramiding to allow multiple long entries when qualifying conditions appear. This is mainly intended to study whether adding into a trend after pullbacks improves or worsens the tested behavior.

Users should review this setting carefully. Pyramiding increases exposure and can materially increase both potential returns and potential drawdowns.

Default strategy properties

The script uses the following default strategy properties:

- Initial capital: 1,000
- Position sizing: percent of equity
- Default order size: 33% of equity
- Pyramiding: 3
- Commission: 0.1%
- Slippage: defined in the strategy settings
- Bar magnifier: disabled
- Calculate on every tick: disabled
- Process orders on close: disabled

These settings are included for testing purposes only. They may not be suitable for every market, timeframe, or trader. Users should adjust position sizing, commission, slippage, pyramiding, and test date range to reflect realistic conditions for the instrument being tested.

Important backtesting note

TradingView strategy results are simulations based on historical bar data. They are not live trading results.

Backtest results can change significantly depending on:

- Symbol
- Timeframe
- Date range
- Commission
- Slippage
- Liquidity
- Spread
- EMA length
- ADX threshold
- ATR length
- Pullback multiplier
- Minimum bars between entries
- EMA cross mode
- Whether EMA cross signals are used for orders
- Pyramiding setting
- Market regime

Users should test the strategy on a sufficiently large sample of trades and across different market conditions before drawing conclusions. A small number of trades is not enough to evaluate a strategy reliably.

How to use it

A practical workflow is:

1. Select the symbol and timeframe to test.
2. Use a realistic date range that includes different market conditions.
3. Review whether the strategy produces a sufficient number of trades.
4. Adjust commission and slippage to match the market being tested.
5. Review the impact of position size and pyramiding on drawdown.
6. Compare results with and without pullback re-entry.
7. Compare results with and without EMA cross signals being used for strategy orders.
8. Forward-test before considering any real-world use.

Inputs

Date Range

- Start Date: first date included in the test.
- End Date: last date included in the test.

Moving Average

- Fast EMA Length: controls the EMA used for trend direction, pullbacks, and cross signals.

DMI / ADX

- DI Length: DMI calculation period.
- ADX Smoothing: smoothing period for ADX.
- ADX minimum to trade: minimum ADX value required for qualifying trend entries.

Pullback Re-entry

- Enable pullback re-entry: enables or disables ATR-based pullback entries.
- Pullback distance × ATR: controls how close price must pull back toward the EMA.
- ATR Length: ATR period used for pullback distance.

Signal Control

- Minimum bars between entries: controls spacing between entries.

EMA 40 Cross Signals

- Use EMA 40 cross buy/sell signals: enables visual EMA cross signals.
- EMA cross detection mode: chooses Close mode or Wick mode.
- Use EMA cross signals in strategy orders: determines whether EMA cross signals affect actual strategy orders.

Visual elements

The script plots:

- The EMA line, colored by slope.
- Base entry markers.
- Pullback add-entry markers.
- Optional EMA cross buy/sell markers.
- Hidden ADX and ADX threshold plots available for reference.

Limitations

This strategy is long-side focused and does not create independent short positions.

The strategy can underperform during sideways or choppy market conditions, even with the ADX filter.

EMA-based systems are inherently lagging because moving averages react to prior price data.

ADX can confirm trend strength but does not determine trade direction by itself.

Pullback and pyramiding logic can increase exposure and may increase drawdown.

No strategy setting can guarantee profitability or future performance.

Recommended use

This strategy is best used as an educational framework for testing EMA trend continuation, ATR-based pullback re-entry, ADX trend-strength filtering, and pyramiding behavior.

It should be used with realistic backtesting assumptions, conservative risk controls, and additional independent analysis before any trading decision.

## Source Code

````pine
//@version=6
strategy(
     "EMA 40 Pullback Pyramid Strategy",
     overlay              = true,
     initial_capital      = 1000,
     default_qty_type     = strategy.percent_of_equity,
     default_qty_value    = 33,
     pyramiding           = 3,
     commission_type      = strategy.commission.percent,
     commission_value     = 0.1,
     slippage             = 1,
     margin_long          = 0,
     margin_short         = 0,
     use_bar_magnifier    = false,
     calc_on_order_fills  = false,
     calc_on_every_tick   = false,
     process_orders_on_close = false)

// Date range
startDate = input.time(timestamp("2018-01-01T00:00:00"), "Start Date")
endDate   = input.time(timestamp("2069-12-31T00:00:00"), "End Date")
timeCondition = time >= startDate and time <= endDate

// Moving average
fastLen = input.int(40, "Fast EMA length")

// DMI / ADX
diLen     = input.int(14, "DI length")
adxSmooth = input.int(14, "ADX smoothing")
adxThresh = input.float(20, "ADX min. to trade")

// Pullback re-entry
usePullback = input.bool(true, "Enable pullback re-entry")
pullbackAtr = input.float(1.0, "Pullback distance x ATR", minval = 0.0, step = 0.1, active = usePullback)
atrLen      = input.int(14, "ATR length", active = usePullback)

// Signal control
minBarsBetweenEntries = input.int(5, "Minimum bars between entries", minval = 0)

// EMA 40 cross signals
useEmaCrossSignals = input.bool(true, "Use EMA 40 cross buy/sell signals")
emaCrossMode       = input.string("Close", "EMA cross detection mode", options = ["Close", "Wick"])
emaCrossForOrders  = input.bool(true, "Use EMA cross signals in strategy orders")

// Core series
fast = ta.ema(close, fastLen)
[diP, diM, adxV] = ta.dmi(diLen, adxSmooth)
atrV = ta.atr(atrLen)

colUp   = fast > fast[1]
colDown = fast < fast[1]

// True one-way flips only
bullFlip = colUp and not colUp[1]
bearFlip = colDown and not colDown[1]

// Entry / exit logic
trendIn = colUp and adxV > adxThresh

baseEntry = bullFlip and adxV > adxThresh

touchedFast = low <= fast + atrV * pullbackAtr
recovered   = close > fast and close > open

var bool pullbackArmed = false
pullbackCandidate = usePullback and trendIn and (pullbackArmed or touchedFast) and recovered and not baseEntry

// EMA 40 breakout / breakdown logic
emaBuyClose  = ta.crossover(close, fast)
emaSellClose = ta.crossunder(close, fast)

emaBuyWick  = low <= fast and close > fast
emaSellWick = high >= fast and close < fast

emaBuySignal = useEmaCrossSignals and timeCondition and (
     emaCrossMode == "Close" ? emaBuyClose : emaBuyWick)

emaSellSignal = useEmaCrossSignals and timeCondition and (
     emaCrossMode == "Close" ? emaSellClose : emaSellWick)

// Original exit
exitSignal = bearFlip

var int lastEntryBar = na
canEnter = na(lastEntryBar) or bar_index - lastEntryBar >= minBarsBetweenEntries

// Orders
longCond = (
     baseEntry or 
     pullbackCandidate or 
     (emaCrossForOrders and emaBuySignal)
     ) and canEnter and timeCondition

exitCond = (
     exitSignal or 
     (emaCrossForOrders and emaSellSignal)
     ) and timeCondition

if longCond
    strategy.entry("L", strategy.long)
    lastEntryBar := bar_index

if exitCond
    strategy.close_all()

// Update pullback state
if not trendIn or exitCond
    pullbackArmed := false
else if pullbackCandidate
    pullbackArmed := false
else if touchedFast
    pullbackArmed := true

// Plots
plot(fast, title = "Fast EMA",
     color = colUp ? color.green : colDown ? color.red : color.gray,
     linewidth = 3)

plot(adxV, title = "ADX", color = color.blue, display = display.none)

hline(adxThresh, title = "ADX threshold",
     color = color.gray, linestyle = hline.style_dotted, display = display.none)

// Original signals
plotshape(baseEntry and canEnter and timeCondition,
     title = "Base entry",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.green, 0),
     size = size.tiny,
     text = "BUY")

plotshape(pullbackCandidate and canEnter and timeCondition,
     title = "Pullback entry",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.aqua, 0),
     size = size.tiny,
     text = "ADD")

plotshape(exitSignal and timeCondition,
     title = "Original EMA slope sell",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.new(color.red, 0),
     size = size.small,
     text = "SELL",
     display = display.none)

// EMA 40 cross visual signals
plotshape(emaBuySignal,
     title = "Buy signal",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.blue, 0),
     size = size.small,
     text = "BUY")

plotshape(emaSellSignal,
     title = "Sell signal",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.new(color.orange, 0),
     size = size.small,
     text = "SELL")
````
