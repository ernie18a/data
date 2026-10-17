# WhaleCrew Backtester

- url: https://www.tradingview.com/script/6gz8Vu8v-WhaleCrew-Backtester/
- type: strategy
- pine_id: PUB;ede565a0708e4469aa8ae9128a65b254
- version: 1.0

## Description

[b]Backtesting indicators[/b] is [b]easy[/b], just add the following line of code to your script:
[i]plot(longEntry ? 1 : shortEntry ? -1 : longTP ? 0.5 : shortTP ? -0.5 : 0, color=na, editable=false, title='Backtest')[/i]
These numbers are defined as constants in the backtester source-code.

After adding this indicator to your chart:
1. Open Settings
2. Select supported indicator to backtest
3. Select if you want to enter Longs and/or Shorts
4. Open the 'Strategy Tester' at the bottom to check the performance

Remember:
[list]
[*]past performance is not indicative of future results
[*]repainting indicators will create wrong/unrealistic results
[/list]

## Source Code

````pine
//@version=5

//Constants
var LONG = 1
var LONG_TP = 0.5
var SHORT = -1
var SHORT_TP = -0.5

strategy('WhaleCrew Backtester')

i_input = input.source(ohlc4, 'Select "Indicator: Backtest" (Backtest-Plot)', group='Indicator', tooltip='Select Backtest-Plot (e.g. "WhaleCrew Vision: Backtest") of a supported indicator')
i_longPositions = input.bool(true, 'Enter Long Positions', group='Settings')
i_shortPositions = input.bool(true, 'Enter Short Positions', group='Settings')

//Current market position
position = strategy.position_size < 0 ? SHORT : strategy.position_size > 0 ? LONG : 0

if i_input == LONG and i_longPositions
    strategy.close('Short', when=position == SHORT)
    strategy.entry('Long', strategy.long, 10)
    label.new(bar_index, -10, style=label.style_label_up, size=size.tiny, text='Entry', color=color.new(color.lime, 20), textcolor=color.white)
    
if i_input == LONG_TP and position == LONG
    label.new(bar_index, 0, style=label.style_label_down, size=size.tiny, text='TP', color=color.new(color.red, 20), textcolor=color.white)
    strategy.close('Long')
    
if i_input == SHORT and i_shortPositions
    strategy.close('Long', when=position == LONG)
    strategy.entry('Short', strategy.short, 10)
    label.new(bar_index, 10, style=label.style_label_down, size=size.tiny, text='Entry', color=color.new(color.red, 20), textcolor=color.white)

if i_input == SHORT_TP and position == SHORT
    label.new(bar_index, 0, style=label.style_label_up, size=size.tiny, text='TP', color=color.new(color.lime, 20), textcolor=color.white)
    strategy.close('Short')
````
