# Donchian Channels strategy with backtest

- url: https://www.tradingview.com/script/SlYz8Ptk-Donchian-Channels-strategy-with-backtest/
- type: strategy
- pine_id: PUB;42719992cb9a4fd89078769a16519c07
- version: 4.0

## Description

Here's another trading strategy for you. This one is based on the standard Donchian Channels.

This one will - by default - wait for 2 consecutive higher highs (or lower lows) before taking a position. This can be disabled so the script will take a new trade without waiting for the 2nd high or low.
This is useful to avoid getting into a trade when market makers are aiming for a swing-failure pattern (= taking out stop/losses below the last low or above the last high)

For people who don't like to short, there's also the option to exclude shorts.

Enjoy!

## Source Code

````pine
//@version=4
//#################
//####CHANGELOG####
//#################
//v2: Added buy/sell/close labels

strategy(title="Donchian Channels", shorttitle="DC", overlay=true, initial_capital=10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, calc_on_every_tick=true)
length = input(20, minval=1)
lower = lowest(length)
upper = highest(length)
basis = avg(upper, lower)
var inShortPos = false
var inLongPos = false
bool wait4confirmation = input(true, title="Wait for double confirmation?")
bool doShort = input(true, title="Include short positions")
bool plotBuyLabel = false
bool plotSellLabel = false
bool plotCloseLabel = false

plot(basis, "Basis", color=#FF6D00)
u = plot(upper, "Upper", color=#2962FF)
l = plot(lower, "Lower", color=#2962FF)
fill(u, l, color=color.rgb(33, 150, 243, 95), title="Background")

if(not inLongPos and upper > upper[1])
    if(wait4confirmation)
        if(not inLongPos and upper > upper[1] and upper[1] > upper[2])
            strategy.close("Short", true)
            strategy.entry("Buy", true)
            inLongPos := true
            inShortPos := false
            plotBuyLabel := true
    else
        strategy.close("Short", true)
        strategy.entry("Buy", true)
        inLongPos := true
        inShortPos := false
        plotBuyLabel := true
else
    if(not inShortPos and lower < lower[1])
        if(wait4confirmation)
            if(not inShortPos and lower < lower[1] and lower[1] < lower[2])
                if(inLongPos and not doShort)
                    strategy.close("Buy", true)
                    inLongPos := false
                    plotCloseLabel := true
                if(doShort)
                    strategy.close("Buy", true)
                    strategy.entry("Short", false)
                    inLongPos := false
                    inShortPos := true
                    plotSellLabel := true
        else
            if(inLongPos and not doShort)
                strategy.close("Buy", true)
                inLongPos := false
                plotCloseLabel := true
            if(doShort)
                strategy.close("Buy", true)
                strategy.entry("Short", false)
                inShortPos := true
                inLongPos := false
                plotSellLabel := true
                
plotshape(plotBuyLabel, text="Buy", title="Buy Signal", style=shape.labelup, color=color.lime, textcolor=color.black, location=location.belowbar,size=size.large)
plotshape(plotSellLabel, text="Sell", title="Sell Signal", style=shape.labeldown, color=color.red, textcolor=color.white, location=location.abovebar,size=size.large)
plotshape(plotCloseLabel, text="Close", title="Close Signal", style=shape.labeldown, color=color.orange, textcolor=color.white, location=location.abovebar,size=size.large)
````
