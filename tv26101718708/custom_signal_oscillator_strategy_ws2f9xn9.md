# Custom Signal Oscillator Strategy

- url: https://www.tradingview.com/script/ws2F9XN9-Custom-Signal-Oscillator-Strategy/
- type: strategy
- pine_id: PUB;2792a8f9c11e4b14a446f6e2cbf03f5f
- version: 3.0

## Description

The CSO is made to help traders easily test their theories by subtracting the difference between two customizable plots(indicators) without having to search for strategies. The general purpose is to provide a tool to users without coding knowledge.

How to use :

[list]
[*]Apply the indicator(s) to test
[/list]

[list]
[*]Go to the CSO strategy input settings and select the desired plots from the added indicators. (The back test will enter long or short depending on the fast signal crosses on the slow signal)
[/list]

[list]
[*]Pull up the strategy tester
[/list]

[list]
[*]Adjust the input settings on the selected indicator(s) to back test
[/list]

For example, the published strategy is using the basis lines from two Donchian channels with varying length. This can be utilized with multiple overlays on the chart and oscillators that are operating on the same scale with each other. Since chart glows aren't extremely common, a glow option is included to stand out on the chart as the chain operator. A long only option for is also included for versatility.

## Source Code

````pine
// © NantzOS

//@version=6
strategy('Custom Signal Oscillator Strategy', shorttitle = 'CSO-TEST', overlay = false)

// Input: Select two plots
plot1 = input(open, title = 'Fast Signal')
plot2 = input(close, title = 'Slow Signal')

// Input: Enable glow colors
enableGlow = input.bool(true, title = 'Enable Glow Colors')

// Input: Long only option
longOnly = input.bool(false, title = 'Long Only')

// Calculate the difference
oscillator = plot1 - plot2

// Plot the oscillator with a glow effect if enabled
plot(oscillator, title = 'Oscillator', color = color.new(color.white, 20), linewidth = 1)
plot(oscillator, title = 'Oscillator Glow 1', color = enableGlow ? color.new(color.fuchsia, 50) : na, linewidth = math.max(1, enableGlow ? 4 : na))
plot(oscillator, title = 'Oscillator Glow 2', color = enableGlow ? color.new(color.fuchsia, 70) : na, linewidth = math.max(1, enableGlow ? 8 : na))

// Adding zero line for reference
hline(0, 'Zero Line', color = color.gray)

// Long and Short Entries
longEntry = ta.crossover(oscillator, 0)
shortEntry = ta.crossunder(oscillator, 0)

// Long Exit (for long-only mode)
longExit = ta.crossunder(oscillator, 0)

// Plot shapes for entries and exits
plotshape(series = longEntry, style = shape.triangleup, location = location.bottom, color = color.rgb(0, 230, 118, 50), size = size.tiny, title = 'Cross Over')
plotshape(series = shortEntry, style = shape.triangledown, location = location.top, color = color.rgb(136, 14, 79, 50), size = size.tiny, title = 'Cross Under')

// Strategy entries and exits
if longEntry
    strategy.entry('Long', strategy.long)

if longExit and longOnly
    strategy.close('Long')

if shortEntry and not longOnly
    strategy.entry('Short', strategy.short)

// Alert Conditions
alertcondition(longEntry, title = 'Long Entry/Short Exit', message = 'BUY')
alertcondition(shortEntry or longExit, title = 'Short Entry/Long Exit', message = 'SELL')

//______ _________ 
//___  //_/__  __ \
//__  ,<  __  /_/ /
//_  /| | _  ____/ 
///_/ |_| /_/
````
