# Source Strategy

- url: https://www.tradingview.com/script/RCLU3bZA-Source-Strategy/
- type: strategy
- pine_id: PUB;957fa8aeeddb44828b4f6fd661001885
- version: 7.0

## Description

This strategy converts indicator signals into long and short entries and exits. It looks for non-zero values from your chosen entry sources to enter positions, and from exit sources to close positions.

The strategy supports both longs and shorts. For long trades, it looks at your selected long source and long exit source; for short trades, it looks at your chosen short source and short exit source. The strategy enters a position when either source produces any value except zero.

Stop loss and take profit orders are incorporated for risk management. These orders are calculated as a percentage of your position's value, providing dynamic risk management as price moves. The percentage levels for stop loss and take profit orders are configurable in the settings, allowing you to adjust your risk parameters based on market conditions and trading style.

To use the strategy, add it to your chart. The input parameters can be configured in the strategy's settings panel, including your signal sources for long and short entries and exits, and the percentage levels for stop loss and take profit orders.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AmineLamuadni

//@version=6
strategy('Source Strategy', overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, currency = currency.USDT, commission_type = strategy.commission.percent, commission_value = 0.05, process_orders_on_close = true)

// Entries
var entriesGroup = 'Entries'
useLongEntry = input.bool(true, 'Use Long Entry', tooltip = 'Enable entering long positions based on the specified source.', group = entriesGroup)
longSource = input.source(close, 'Long Source', tooltip = 'Select the output of an indicator to use for long entry signals.', group = entriesGroup)
useLongExclude = input.bool(false, 'Use Long Exclude', tooltip = 'Enable excluding long entries based on the specified source.', group = entriesGroup)
longExcludeSource = input.source(close, 'Long Exclude Source', tooltip = 'Select the output of an indicator to exclude long entries when non-zero.', group = entriesGroup)
useLongEntryWithPosition = input.bool(false, 'Use Long Entry With Position', tooltip = 'Enable entering long positions while having a position.', group = entriesGroup)
useShortEntry = input.bool(false, 'Use Short Entry', tooltip = 'Enable entering short positions based on the specified source.', group = entriesGroup)
shortSource = input.source(close, 'Short Source', tooltip = 'Select the output of an indicator to use for short entry signals.', group = entriesGroup)
useShortExclude = input.bool(false, 'Use Short Exclude', tooltip = 'Enable excluding short entries based on the specified source.', group = entriesGroup)
shortExcludeSource = input.source(close, 'Short Exclude Source', tooltip = 'Select the output of an indicator to exclude short entries when non-zero.', group = entriesGroup)
useShortEntryWithPosition = input.bool(false, 'Use Short Entry With Position', tooltip = 'Enable entering short positions while having a position.', group = entriesGroup)

// Exits
var exitsGroup = 'Exits'
useLongExit = input.bool(false, 'Use Long Exit', tooltip = 'Enable exiting long positions based on the specified source.', group = exitsGroup)
longExitSource = input.source(close, 'Long Exit Source', tooltip = 'Select the output of an indicator to use for long exit signals.', group = exitsGroup)
useLongExitExclude = input.bool(false, 'Use Long Exit Exclude', tooltip = 'Enable excluding long exits based on the specified source.', group = exitsGroup)
longExitExcludeSource = input.source(close, 'Long Exit Exclude Source', tooltip = 'Select the output of an indicator to exclude long exits when non-zero.', group = exitsGroup)
useShortExit = input.bool(false, 'Use Short Exit', tooltip = 'Enable exiting short positions based on the specified source.', group = exitsGroup)
shortExitSource = input.source(close, 'Short Exit Source', tooltip = 'Select the output of an indicator to use for short exit signals.', group = exitsGroup)
useShortExitExclude = input.bool(false, 'Use Short Exit Exclude', tooltip = 'Enable excluding short exits based on the specified source.', group = exitsGroup)
shortExitExcludeSource = input.source(close, 'Short Exit Exclude Source', tooltip = 'Select the output of an indicator to exclude short exits when non-zero.', group = exitsGroup)

// Risk Management
var riskGroup = 'Risk Management'
useStopLoss = input.bool(true, 'Use Stop Loss', tooltip = 'Enable stop loss orders to limit potential losses on trades.', group = riskGroup)
slPercent = input.float(1.0, 'SL %', minval = 0.1, maxval = 100.0, step = 0.1, tooltip = 'Percentage of the position value to use for the stop loss order. A higher value means a wider stop.', group = riskGroup)
useTakeProfit = input.bool(true, 'Use Take Profit', tooltip = 'Enable take profit orders to automatically close winning trades.', group = riskGroup)
tpPercent = input.float(3.0, 'TP %', minval = 0.1, maxval = 100.0, step = 0.1, tooltip = 'Percentage of the position value to use for the take profit order. A higher value means a larger profit target.', group = riskGroup)
useTrailingStop = input.bool(false, 'Use Trailing Stop', tooltip = 'Enable trailing stop orders to automatically move stops with price.', group = riskGroup)
trailPointsPercent = input.float(3.0, 'Trail Points %', minval = 0.1, maxval = 100.0, step = 0.1, tooltip = 'Percentage of the position value to use for the trail points. A higher value means a larger activation distance.', group = riskGroup)
trailOffsetPercent = input.float(1.0, 'Trail Offset %', minval = 0.1, maxval = 100.0, step = 0.1, tooltip = 'Percentage of the position value to use for the trail offset. A higher value means a wider trailing distance.', group = riskGroup)

// Long Entry
if useLongEntry and longSource != 0 and (not useLongExclude or longExcludeSource == 0) and (useLongEntryWithPosition or strategy.position_size == 0)
    strategy.entry('Long', strategy.long)

// Long Exit
if strategy.position_size > 0
    float stop = strategy.position_avg_price - ((strategy.position_avg_price * strategy.position_size * slPercent) / (100 * strategy.position_size))
    float limit = strategy.position_avg_price + ((strategy.position_avg_price * strategy.position_size * tpPercent) / (100 * strategy.position_size))
    float trailPoints = (strategy.position_avg_price * strategy.position_size * trailPointsPercent) / (100 * strategy.position_size) / syminfo.mintick
    float trailOffset = (strategy.position_avg_price * strategy.position_size * trailOffsetPercent) / (100 * strategy.position_size) / syminfo.mintick

    if useStopLoss and useTakeProfit
        strategy.exit('Long Exit', 'Long', stop = stop, limit = limit, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useStopLoss
        strategy.exit('Long Exit', 'Long', stop = stop, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useTakeProfit
        strategy.exit('Long Exit', 'Long', limit = limit, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useTrailingStop
        strategy.exit('Long Exit', 'Long', trail_points = trailPoints, trail_offset = trailOffset)

// Long Clsoe
if useLongExit and longExitSource != 0 and (not useLongExitExclude or longExitExcludeSource == 0) and strategy.position_size > 0
    strategy.close('Long', immediately=true)

// Short Entry
if useShortEntry and shortSource != 0 and (not useShortExclude or shortExcludeSource == 0) and (useShortEntryWithPosition or strategy.position_size == 0)
    strategy.entry('Short', strategy.short)

// Short Exit
if strategy.position_size < 0
    float stop = strategy.position_avg_price + ((strategy.position_avg_price * strategy.position_size * slPercent) / (100 * strategy.position_size))
    float limit = strategy.position_avg_price - ((strategy.position_avg_price * strategy.position_size * tpPercent) / (100 * strategy.position_size))
    float trailPoints = (strategy.position_avg_price * strategy.position_size * trailPointsPercent) / (100 * strategy.position_size) / syminfo.mintick
    float trailOffset = (strategy.position_avg_price * strategy.position_size * trailOffsetPercent) / (100 * strategy.position_size) / syminfo.mintick

    if useStopLoss and useTakeProfit
        strategy.exit('Short Exit', 'Short', stop = stop, limit = limit, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useStopLoss
        strategy.exit('Short Exit', 'Short', stop = stop, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useTakeProfit
        strategy.exit('Short Exit', 'Short', limit = limit, trail_points = useTrailingStop ? trailPoints : na, trail_offset = useTrailingStop ? trailOffset : na)
    else if useTrailingStop
        strategy.exit('Short Exit', 'Short', trail_points = trailPoints, trail_offset = trailOffset)

// Short Close
if useShortExit and shortExitSource != 0 and (not useShortExitExclude or shortExitExcludeSource == 0) and strategy.position_size < 0
    strategy.close('Short', immediately=true)
````
