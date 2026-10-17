# Pivot Strategy [OmegaTools]

- url: https://www.tradingview.com/script/tU2nzJzP-Pivot-Strategy-OmegaTools/
- type: strategy
- pine_id: PUB;20ffe245feed438a9907300e5b828bfe
- version: 1.0

## Description

Pivot Strategy by OmegaTools is a systematic trading strategy designed to evaluate price behavior around key pivot point levels. The script builds a complete pivot framework using the selected calculation method, with support for Traditional, Fibonacci, Woodie, Classic, and Camarilla pivots. From this structure, the strategy derives the central pivot level together with the first three resistance and support extensions, creating a clear and objective map of potential reaction zones for the session.

This script shouldn't be used as a stand alone strategy, a proper trigger and confluence filters are missing, instead try using this script to study market reaction to key levels in order to be able to create and test your own strategy.

The strategy is built around two distinct execution models. In TF mode, it operates as a breakout system, entering long positions when price closes upward through the selected bullish pivot level and entering short positions when price closes downward through the selected bearish pivot level. In MR mode, the logic shifts to a mean reversion framework, taking the opposite side of a level interaction: a touch of the selected support-side level from above can trigger a long entry, while a touch of the selected resistance-side level from below can trigger a short entry. This dual structure allows the script to be adapted to both continuation-driven and reversal-driven market conditions.

Entry selection is configurable through the central pivot or through one of the first three support/resistance tiers, allowing traders to test different degrees of aggressiveness and selectivity. A central-pivot configuration may produce more frequent signals, while higher-level entries such as SR2 or SR3 generally focus on more extended price movement before participation. This makes the strategy suitable not only for direct backtesting, but also for comparative research across instruments, volatility regimes, and pivot methodologies.

Risk management is handled through pivot-based exit logic. Stop loss and take profit levels are independently configurable and are mapped directly to the pivot structure. For long positions, stop losses are derived from the support side and take profits from the resistance side. For short positions, the inverse logic is applied. The script also validates these levels relative to the average entry price, so exits remain structurally coherent with the active position. This keeps the framework simple, transparent, and fully anchored to the same pivot environment used for entries.

To reinforce execution discipline, the strategy includes a maximum trades per day parameter, limiting the number of entries allowed during each reset cycle. At the beginning of a new reset period, the strategy clears its internal trade counter and closes any open position, ensuring that each new session starts independently from the previous one. This design makes the model particularly useful for traders who want strict session-based behavior and clean daily segmentation in their testing.

Overall, Pivot Strategy [OmegaTools] is intended for traders and quantitative researchers seeking a structured way to test pivot-driven breakout and mean reversion behavior with clearly defined rules. It is especially useful for studying how different pivot formulas, entry locations, and exit configurations influence performance across markets and timeframes, while maintaining a consistent and interpretable framework.

Disclaimer: This script is provided for educational and research purposes only. It does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any financial instrument. Past performance, backtest results, and hypothetical simulations are not indicative of future results. Market conditions, slippage, commissions, execution differences, and instrument-specific factors can materially affect real-world performance. Users should conduct their own analysis, apply proper risk management, and perform thorough out-of-sample validation before considering any live use.

## Source Code

````pine
// © OmegaTools

//@version=6
strategy("Pivot Strategy [OmegaTools]", overlay=true, fill_orders_on_standard_ohlc = true)

// Inputs

typ = input.string('Woodie', 'Type', ['Traditional', 'Fibonacci', 'Woodie', 'Classic', 'Camarilla'])
reset = timeframe.change(input.timeframe('1D', 'Reset'))
entry = input.string('M', 'Entry', ['M', 'SR1', 'SR2', 'SR3'], inline = 'entry', group = 'Strategy')
entry2 = input.string('TF', '', ['TF', 'MR'], inline = 'entry', group = 'Strategy')
stoploss = input.string('SR1', 'Stop Loss', ['None', 'M', 'SR1', 'SR2', 'SR3'], group = 'Strategy')
takeprofit = input.string('SR3', 'Take Profit', ['None', 'M', 'SR1', 'SR2', 'SR3'], group = 'Strategy')
maxtrades = input.int(1, 'Max trades per day', group = 'Strategy')

upc = input.color(#2962ff, 'Colors', inline = 'col')
dnc = input.color(#e91e63, '', inline = 'col')

// Calculations

piv = ta.pivot_point_levels(typ, reset)

p0 = piv.get(0)
r1 = piv.get(1)
s1 = piv.get(2)
r2 = piv.get(3)
s2 = piv.get(4)
r3 = piv.get(5)
s3 = piv.get(6)

// Plotting

plot(not reset ? p0 : na, 'Pivot M', color.from_gradient(0, -1, 1, upc, dnc), 1, plot.style_linebr, display = display.pane)
plot(not reset ? r1 : na, 'Pivot R1', dnc, 1, plot.style_linebr, display = display.pane)
plot(not reset ? s1 : na, 'Pivot S1', upc, 1, plot.style_linebr, display = display.pane)
plot(not reset ? r2 : na, 'Pivot R2', dnc, 1, plot.style_linebr, display = display.pane)
plot(not reset ? s2 : na, 'Pivot S2', upc, 1, plot.style_linebr, display = display.pane)
plot(not reset ? r3 : na, 'Pivot R3', dnc, 1, plot.style_linebr, display = display.pane)
plot(not reset ? s3 : na, 'Pivot S3', upc, 1, plot.style_linebr, display = display.pane)

// Trading

getLongLevel(sel) =>
    switch sel
        'M'   => p0
        'SR1' => r1
        'SR2' => r2
        'SR3' => r3
        => na

getShortLevel(sel) =>
    switch sel
        'M'   => p0
        'SR1' => s1
        'SR2' => s2
        'SR3' => s3
        => na

entryLongLevel  = getLongLevel(entry)
entryShortLevel = getShortLevel(entry)

longSignal = entry2 == 'TF' ? close[1] < entryLongLevel and close >= entryLongLevel  : close[1] > entryShortLevel and low <= entryShortLevel
shortSignal = entry2 == 'TF' ? close[1] > entryShortLevel and close <= entryShortLevel : close[1] < entryLongLevel and high >= entryLongLevel

var int tradesToday = 0
if reset
    tradesToday := 0
    strategy.close_all(comment = 'Pivot Reset')

canTrade = tradesToday < maxtrades

if canTrade
    if longSignal and not shortSignal and strategy.position_size <= 0
        strategy.entry('Long', strategy.long)
        tradesToday += 1
    else if shortSignal and not longSignal and strategy.position_size >= 0
        strategy.entry('Short', strategy.short)
        tradesToday += 1

longSLraw = stoploss   == 'None' ? na : getShortLevel(stoploss)
longTPraw = takeprofit == 'None' ? na : getLongLevel(takeprofit)
shortSLraw = stoploss   == 'None' ? na : getLongLevel(stoploss)
shortTPraw = takeprofit == 'None' ? na : getShortLevel(takeprofit)

longSL = strategy.position_size > 0 and not na(longSLraw)  and longSLraw  < strategy.position_avg_price ? longSLraw  : na
longTP = strategy.position_size > 0 and not na(longTPraw)  and longTPraw  > strategy.position_avg_price ? longTPraw  : na
shortSL = strategy.position_size < 0 and not na(shortSLraw) and shortSLraw > strategy.position_avg_price ? shortSLraw : na
shortTP = strategy.position_size < 0 and not na(shortTPraw) and shortTPraw < strategy.position_avg_price ? shortTPraw : na

strategy.exit('Long Exit',  from_entry = 'Long',  stop = longSL,  limit = longTP)
strategy.exit('Short Exit', from_entry = 'Short', stop = shortSL, limit = shortTP)

// End of Script
````
