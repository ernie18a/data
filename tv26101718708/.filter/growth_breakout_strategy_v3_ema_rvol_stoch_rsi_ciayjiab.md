# Growth Breakout Strategy v3 - EMA + RVOL + Stoch RSI

- url: https://www.tradingview.com/script/cIaYJiab-Growth-Breakout-Strategy-v3-EMA-RVOL-Stoch-RSI/
- type: strategy
- pine_id: PUB;4563d378cc274c73a07ad721bcd09a9d
- version: 1.0

## Description

Growth Breakout Strategy v3 - EMA + RVOL + Stoch RSI

This strategy is designed to identify high-momentum breakout setups in growth stocks by combining trend structure, consolidation, relative volume, proximity to 52-week highs, and Stoch RSI momentum confirmation.

Strategy Logic

The core idea is to look for stocks that are already showing strength, consolidating near key moving averages, and then breaking out with above-average volume.

The strategy looks for:

1. Consolidation near the fast EMA

Price must be within a configurable percentage of the fast EMA, defaulted to the 20 EMA.

This is intended to identify stocks that are tightening near short-term support instead of chasing extended moves.

2. Proximity to 52-week highs

Price must be within a configurable percentage of its 52-week high.

The default setting requires price to be within 5% of the 52-week high.

This helps focus the strategy on stocks with strong relative strength and avoids weaker names trading far below prior highs.

3. Breakout above recent highs

Price must close above the highest high of the prior breakout lookback period.

The default lookback is 10 bars.

This acts as the actual breakout trigger.

4. Relative Volume confirmation

The breakout must occur with elevated volume.

The default RVOL threshold is 1.5x the recent average volume.

This helps confirm that the move has meaningful participation rather than being a low-volume false breakout.

5. EMA trend filter

The strategy includes an EMA-based trend confirmation filter.

By default, it allows entries when the fast EMA crosses above the slow EMA or when price is trading above the fast EMA.

This helps confirm short-term bullish momentum.

6. Stoch RSI confirmation

The strategy includes an optional Stoch RSI momentum filter.

By default, Stoch RSI must be bullish, with the K line above the D line, while remaining below the overbought threshold.

This is designed to avoid buying when momentum is already overly extended.

Entry Rules

A long entry is triggered when all enabled conditions are true:

- Price is consolidating near the fast EMA
- Price is near its 52-week high
- Price breaks above the recent breakout high
- Relative volume is above the selected threshold
- EMA filter passes
- Stoch RSI filter passes

The strategy is long-only.

Exit Rules

The script includes multiple configurable exit modes:

- 50 EMA Crossunder
- 20 EMA Crossunder
- Percent Stop
- Percent Stop + Target
- ATR Stop
- ATR Stop + Target

The default exit mode is 50 EMA Crossunder.

This means the strategy exits when price crosses below the slow EMA, using the 50 EMA as a trailing support reference.

Suggested Usage

This strategy is intended for growth stocks, momentum names, small caps, and tech stocks where breakout behavior and relative volume are especially important.

It can be used on daily charts for swing trading, or on shorter timeframes for more active trading, but settings should be adjusted based on the timeframe and volatility of the ticker.

Suggested starting settings:

- Fast EMA: 20
- Slow EMA: 50
- Consolidation threshold: 2%
- 52-week high proximity: within 5%
- Breakout lookback: 10 bars
- RVOL threshold: 1.5x
- Stoch RSI max: 80
- Exit mode: 50 EMA Crossunder

For cleaner but fewer signals, consider using:

- RVOL threshold: 2.0x
- Consolidation threshold: 1.5%
- 52-week high proximity: 3%

For more signals, consider using:

- RVOL threshold: 1.2x
- Consolidation threshold: 3%
- 52-week high proximity: 8% to 10%

Visuals

The strategy plots:

- Fast EMA
- Slow EMA
- Prior breakout high
- BREAKOUT labels on long entries
- SELL labels on EMA-based exits
- Optional background highlighting for valid setup bars
- Optional debug table showing whether each condition is passing

Best Practices

This strategy should not be used blindly.

Breakout strategies can perform well in strong trending markets but may struggle in choppy or mean-reverting environments.

Recommended workflow:

1. Use the strategy to scan for potential breakout setups.
2. Confirm the chart structure manually.
3. Check market conditions and sector strength.
4. Avoid low-liquidity names with unreliable volume.
5. Backtest and tune settings per ticker and timeframe.
6. Consider using stop-loss and target exits for more controlled risk.

Important Notes

This is not financial advice.

The strategy is provided for educational and research purposes only.

Past performance does not guarantee future results.

Always backtest thoroughly and use proper risk management before trading live.

## Source Code

````pine
//@version=5
strategy("Growth Breakout Strategy v3 - EMA + RVOL + Stoch RSI", shorttitle="Growth Breakout v3", overlay=true, initial_capital=10000, pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.0, slippage=0, process_orders_on_close=true)

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

exitMode = input.string("50 EMA Crossunder", "Exit Mode", options=["50 EMA Crossunder", "20 EMA Crossunder", "Percent Stop", "Percent Stop + Target", "ATR Stop", "ATR Stop + Target"])

stopLossPct = input.float(7.0, "Stop Loss (%)", minval=0.1, step=0.1)
takeProfitPct = input.float(15.0, "Take Profit (%)", minval=0.1, step=0.1)

atrLen = input.int(14, "ATR Length", minval=1)
atrStopMult = input.float(2.5, "ATR Stop Multiplier", minval=0.1, step=0.1)
atrTargetMult = input.float(4.0, "ATR Target Multiplier", minval=0.1, step=0.1)

useEquitySizing = input.bool(true, "Use Percent of Equity Position Sizing")
positionPct = input.float(100.0, "Position Size % of Equity", minval=1.0, maxval=100.0, step=1.0)
fixedQty = input.float(1.0, "Fixed Share Quantity", minval=0.0001)

showLabels = input.bool(true, "Show Buy/Sell Labels")
showBackground = input.bool(false, "Highlight Valid Setup Background")
showDebugTable = input.bool(true, "Show Debug Table")

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

atr = ta.atr(atrLen)

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

longCondition = isConsolidating and nearHighs and breakout and emaFilterPassed and stochFilterPassed
canEnter = longCondition and strategy.position_size == 0

qty = useEquitySizing ? strategy.equity * (positionPct / 100) / close : fixedQty

// Entries
if canEnter
    strategy.entry("Growth Long", strategy.long, qty=qty)

// Exits
inPosition = strategy.position_size > 0
entryPrice = strategy.position_avg_price

percentStopPrice = entryPrice * (1 - stopLossPct / 100)
percentTargetPrice = entryPrice * (1 + takeProfitPct / 100)

atrStopPrice = entryPrice - atr * atrStopMult
atrTargetPrice = entryPrice + atr * atrTargetMult

exitOn50Ema = ta.crossunder(close, emaSlow)
exitOn20Ema = ta.crossunder(close, emaFast)

if inPosition and exitMode == "50 EMA Crossunder" and exitOn50Ema
    strategy.close("Growth Long", comment="Exit 50 EMA")

if inPosition and exitMode == "20 EMA Crossunder" and exitOn20Ema
    strategy.close("Growth Long", comment="Exit 20 EMA")

if inPosition and exitMode == "Percent Stop"
    strategy.exit("Percent Stop Exit", from_entry="Growth Long", stop=percentStopPrice)

if inPosition and exitMode == "Percent Stop + Target"
    strategy.exit("Percent Stop Target Exit", from_entry="Growth Long", stop=percentStopPrice, limit=percentTargetPrice)

if inPosition and exitMode == "ATR Stop"
    strategy.exit("ATR Stop Exit", from_entry="Growth Long", stop=atrStopPrice)

if inPosition and exitMode == "ATR Stop + Target"
    strategy.exit("ATR Stop Target Exit", from_entry="Growth Long", stop=atrStopPrice, limit=atrTargetPrice)

// Visuals
plot(emaFast, title="Fast EMA", color=color.blue, linewidth=2)
plot(emaSlow, title="Slow EMA", color=color.red, linewidth=2)
plot(priorBreakoutHigh, title="Prior Breakout High", color=color.orange, linewidth=1, style=plot.style_linebr)

plotshape(showLabels and canEnter, title="Growth Breakout Buy Signal", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BREAKOUT", textcolor=color.white, size=size.small)

plotshape(showLabels and inPosition and exitOn50Ema and exitMode == "50 EMA Crossunder", title="50 EMA Exit Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)

plotshape(showLabels and inPosition and exitOn20Ema and exitMode == "20 EMA Crossunder", title="20 EMA Exit Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)

bgcolor(showBackground and longCondition ? color.new(color.green, 85) : na)

// Alerts
alertcondition(canEnter, title="Growth Breakout Buy", message="Growth Breakout BUY signal")
alertcondition(exitOn50Ema and inPosition, title="50 EMA Exit", message="Growth Breakout EXIT - close crossed below 50 EMA")
alertcondition(exitOn20Ema and inPosition, title="20 EMA Exit", message="Growth Breakout EXIT - close crossed below 20 EMA")

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
    table.cell(debugTable, 1, 9, longCondition ? "BUY" : "WAIT", text_color=longCondition ? color.green : color.orange)
````
