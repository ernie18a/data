# Growth Breakout Indicator v3 - EMA + RVOL + Stoch RSI

- url: https://www.tradingview.com/script/XjJqBVdm-Growth-Breakout-Indicator-v3-EMA-RVOL-Stoch-RSI/
- type: indicator
- pine_id: PUB;7b3f271b421641c9913482991b451622
- version: 1.0

## Description

Growth Breakout Indicator v3 - EMA + RVOL + Stoch RSI

This indicator is designed to identify potential high-momentum breakout setups in growth stocks by combining trend structure, consolidation, relative volume, proximity to 52-week highs, and Stoch RSI momentum confirmation.

Unlike the strategy version, this script does not place simulated trades or produce Strategy Tester results. It is an indicator for visual chart signals, alerts, and discretionary trade review.

What This Indicator Does

The indicator looks for stocks that are:

1. Consolidating near a key moving average
2. Trading close to their 52-week highs
3. Breaking above a recent resistance level
4. Showing elevated relative volume
5. Passing optional EMA and Stoch RSI momentum filters

When all enabled conditions are met, the indicator plots a BREAKOUT label below the candle.

Core Signal Logic

1. Consolidation near the fast EMA

Price must be within a configurable percentage of the fast EMA.

The default fast EMA is 20.

The default consolidation threshold is 2%.

This is intended to find stocks tightening near short-term support before a potential breakout.

2. Near 52-week highs

Price must be within a configurable percentage of its 52-week high.

The default setting requires price to be within 5% of the 52-week high.

This helps focus signals on stocks showing relative strength instead of weaker names far below prior highs.

3. Recent high breakout

Price must close above the highest high of the prior breakout lookback period.

The default breakout lookback is 10 bars.

This acts as the actual breakout trigger.

4. Relative Volume confirmation

The breakout must occur with elevated relative volume.

The default RVOL threshold is 1.5x the recent average volume.

This is intended to confirm that the breakout has meaningful participation rather than being a low-volume move.

5. EMA trend filter

The indicator includes an optional EMA trend/momentum filter.

By default, it allows a signal when the fast EMA crosses above the slow EMA or price is trading above the fast EMA.

Default EMAs:

- Fast EMA: 20
- Slow EMA: 50

This helps confirm that price is aligned with bullish short-term momentum.

6. Stoch RSI confirmation

The indicator includes an optional Stoch RSI filter.

By default, Stoch RSI must be bullish:

- Stoch RSI K is above Stoch RSI D
- Stoch RSI K is below the selected overbought threshold

The default max Stoch RSI value is 80.

This is intended to avoid breakouts where momentum may already be exhausted.

Buy Signal

A BREAKOUT label appears when all active conditions are true:

- Price is consolidating near the fast EMA
- Price is near the 52-week high
- Price closes above the recent breakout high
- RVOL is above the selected threshold
- EMA trend filter passes, if enabled
- Stoch RSI filter passes, if enabled

Exit Signal

The indicator can also plot SELL labels based on EMA crossunder logic.

Exit signal modes:

- 50 EMA Crossunder
- 20 EMA Crossunder
- Both

These are not automatic exits. They are visual reference signals only.

Suggested Usage

This indicator is best used as a breakout scanner and chart confirmation tool.

Recommended workflow:

1. Apply the indicator to growth stocks, small caps, momentum names, or tech stocks.
2. Look for BREAKOUT labels near clean consolidation structures.
3. Confirm the chart manually before taking any trade.
4. Check volume, liquidity, broader market trend, and sector strength.
5. Use alerts if you want to be notified when a breakout condition appears.
6. Manage risk manually or with your own trading plan.

Suggested Starting Settings

For swing trading growth stocks:

- Chart timeframe: Daily
- Fast EMA: 20
- Slow EMA: 50
- Consolidation threshold: 2%
- 52-week high proximity: 5%
- Breakout lookback: 10 bars
- RVOL threshold: 1.5
- Stoch RSI max: 80
- Exit signal mode: 50 EMA Crossunder

For cleaner but fewer signals:

- RVOL threshold: 2.0
- Consolidation threshold: 1.5%
- 52-week high proximity: 3%
- Keep Stoch RSI filter enabled

For more frequent signals:

- RVOL threshold: 1.2
- Consolidation threshold: 3%
- 52-week high proximity: 8% to 10%
- Consider disabling the Stoch RSI filter

Visual Elements

The indicator plots:

- Fast EMA
- Slow EMA
- Prior breakout high
- BREAKOUT labels for buy signals
- SELL labels for selected EMA exit signals
- Optional green background highlight on valid setup bars
- Optional debug table showing which conditions are currently passing

Debug Table

The debug table is useful for understanding why a signal is or is not appearing.

It shows:

- Consolidating: whether price is close enough to the fast EMA
- Near 52W High: whether price is close enough to the 52-week high
- Price Breakout: whether price has broken above recent highs
- RVOL: current relative volume reading
- Stoch Bullish: whether Stoch RSI is confirming momentum
- EMA Filter: whether EMA trend/momentum condition is passing
- Distance From EMA: current percentage distance from fast EMA
- Below 52W High: current percentage below the 52-week high
- Final Signal: BUY or WAIT

Alerts

The indicator includes alert conditions for:

- Growth Breakout Buy
- 50 EMA Exit
- 20 EMA Exit
- Selected Exit Signal

To use alerts:

1. Add the indicator to your chart.
2. Click TradingView’s Alert button.
3. Select this indicator as the alert source.
4. Choose the desired alert condition.
5. Configure notification settings.

Best Practices

This indicator should not be used blindly.

Breakout indicators can work well in strong trending markets but may produce false signals in choppy or weak markets.

Before acting on a signal, consider:

- Overall market trend
- Sector strength
- Stock liquidity
- Spread size
- Earnings dates
- News catalysts
- Prior resistance levels
- Volume quality
- Risk/reward setup

Important Notes

This indicator is for educational and research purposes only.

It does not provide financial advice.

It does not guarantee profitable trades.

Past performance does not guarantee future results.

Always backtest, paper trade, and use proper risk management before trading with real capital.

## Source Code

````pine
//@version=5
indicator("Growth Breakout Indicator v3 - EMA + RVOL + Stoch RSI", shorttitle="Growth Breakout v3", overlay=true)

// Inputs
emaFastLen = input.int(20, "Fast EMA Length", minval=1)
emaSlowLen = input.int(50, "Slow EMA Length", minval=1)

consolidationPct = input.float(2.0, "Max Distance From Fast EMA (%)", minval=0.1, step=0.1)

lookback52W = input.int(252, "52-Week High Lookback Bars", minval=20)
nearHighPct = input.float(5.0, "Max Distance Below 52-Week High (%)", minval=0.1, step=0.1)

breakoutLookback = input.int(10, "Breakout Lookback Bars", minval=2)

rvolLen = input.int(20, "RVOL Average Volume Length", minval=1)
rvolThreshold = input.float(1.5, "Minimum Relative Volume", minval=0.1, step=0.1)

rsiLen = input.int(14, "RSI Length", minval=1)
stochLen = input.int(14, "Stochastic RSI Length", minval=1)
kSmooth = input.int(3, "Stoch RSI K Smoothing", minval=1)
dSmooth = input.int(3, "Stoch RSI D Smoothing", minval=1)
stochMax = input.float(80.0, "Max Stoch RSI For Entry", minval=1, maxval=100)

useStochFilter = input.bool(true, "Use Stoch RSI Filter")
useEmaTrendFilter = input.bool(true, "Use EMA Trend Filter")
useEmaCrossOrAbove = input.bool(true, "Allow Fast EMA Cross OR Close Above Fast EMA")

exitMode = input.string("50 EMA Crossunder", "Exit Signal Mode", options=["50 EMA Crossunder", "20 EMA Crossunder", "Both"])

showLabels = input.bool(true, "Show Buy/Sell Labels")
showBackground = input.bool(false, "Highlight Valid Setup Background")
showDebugTable = input.bool(true, "Show Debug Table")
showBreakoutLine = input.bool(true, "Show Prior Breakout High")

// Calculations
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

high52W = ta.highest(high, lookback52W)

avgVolume = ta.sma(volume, rvolLen)
rvol = avgVolume > 0 ? volume / avgVolume : na

rsiValue = ta.rsi(close, rsiLen)
rsiLowest = ta.lowest(rsiValue, stochLen)
rsiHighest = ta.highest(rsiValue, stochLen)
stochRaw = rsiHighest != rsiLowest ? 100 * (rsiValue - rsiLowest) / (rsiHighest - rsiLowest) : 0
stochK = ta.sma(stochRaw, kSmooth)
stochD = ta.sma(stochK, dSmooth)

// Entry conditions
distanceFromFastEmaPct = math.abs(close - emaFast) / close * 100
isConsolidating = distanceFromFastEmaPct <= consolidationPct

distanceBelow52HighPct = high52W > 0 ? (high52W - close) / high52W * 100 : na
nearHighs = close >= high52W * (1 - nearHighPct / 100)

priorBreakoutHigh = ta.highest(high[1], breakoutLookback)
priceBreakout = close > priorBreakoutHigh

volumeBreakout = rvol >= rvolThreshold
breakout = priceBreakout and volumeBreakout

emaTrendBullish = emaFast > emaSlow
emaCross = ta.crossover(emaFast, emaSlow)
emaMomentum = useEmaCrossOrAbove ? emaCross or close > emaFast : emaTrendBullish
emaFilterPassed = useEmaTrendFilter ? emaMomentum : true

stochBullish = stochK > stochD and stochK < stochMax
stochFilterPassed = useStochFilter ? stochBullish : true

buySignal = isConsolidating and nearHighs and breakout and emaFilterPassed and stochFilterPassed

// Exit signals
exitOn50Ema = ta.crossunder(close, emaSlow)
exitOn20Ema = ta.crossunder(close, emaFast)

sellSignal = exitMode == "50 EMA Crossunder" ? exitOn50Ema : exitMode == "20 EMA Crossunder" ? exitOn20Ema : exitOn50Ema or exitOn20Ema

// Visuals
plot(emaFast, title="Fast EMA", color=color.blue, linewidth=2)
plot(emaSlow, title="Slow EMA", color=color.red, linewidth=2)
plot(showBreakoutLine ? priorBreakoutHigh : na, title="Prior Breakout High", color=color.orange, linewidth=1, style=plot.style_linebr)

plotshape(showLabels and buySignal, title="Growth Breakout Buy Signal", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BREAKOUT", textcolor=color.white, size=size.small)

plotshape(showLabels and sellSignal, title="Exit Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)

bgcolor(showBackground and buySignal ? color.new(color.green, 85) : na)

// Alerts
alertcondition(buySignal, title="Growth Breakout Buy", message="Growth Breakout BUY signal on {{ticker}} at {{close}}")
alertcondition(exitOn50Ema, title="50 EMA Exit", message="Growth Breakout EXIT signal on {{ticker}} - close crossed below 50 EMA")
alertcondition(exitOn20Ema, title="20 EMA Exit", message="Growth Breakout EXIT signal on {{ticker}} - close crossed below 20 EMA")
alertcondition(sellSignal, title="Selected Exit Signal", message="Growth Breakout selected SELL signal on {{ticker}} at {{close}}")

// Debug table
var table debugTable = table.new(position.top_right, 2, 10, border_width=1)

if showDebugTable and barstate.islast
    table.cell(debugTable, 0, 0, "Condition", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(debugTable, 1, 0, "Status", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(debugTable, 0, 1, "Consolidating")
    table.cell(debugTable, 1, 1, isConsolidating ? "YES" : "NO", text_color=isConsolidating ? color.green : color.red)
    table.cell(debugTable, 0, 2, "Near 52W High")
    table.cell(debugTable, 1, 2, nearHighs ? "YES" : "NO", text_color=nearHighs ? color.green : color.red)
    table.cell(debugTable, 0, 3, "Price Breakout")
    table.cell(debugTable, 1, 3, priceBreakout ? "YES" : "NO", text_color=priceBreakout ? color.green : color.red)
    table.cell(debugTable, 0, 4, "RVOL")
    table.cell(debugTable, 1, 4, str.tostring(rvol, "#.##"), text_color=volumeBreakout ? color.green : color.red)
    table.cell(debugTable, 0, 5, "Stoch Bullish")
    table.cell(debugTable, 1, 5, stochBullish ? "YES" : "NO", text_color=stochBullish ? color.green : color.red)
    table.cell(debugTable, 0, 6, "EMA Filter")
    table.cell(debugTable, 1, 6, emaFilterPassed ? "YES" : "NO", text_color=emaFilterPassed ? color.green : color.red)
    table.cell(debugTable, 0, 7, "Distance From EMA")
    table.cell(debugTable, 1, 7, str.tostring(distanceFromFastEmaPct, "#.##") + "%")
    table.cell(debugTable, 0, 8, "Below 52W High")
    table.cell(debugTable, 1, 8, str.tostring(distanceBelow52HighPct, "#.##") + "%")
    table.cell(debugTable, 0, 9, "Final Signal")
    table.cell(debugTable, 1, 9, buySignal ? "BUY" : "WAIT", text_color=buySignal ? color.green : color.orange)
````
