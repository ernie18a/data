# 'last red low / last green high' exit

- url: https://www.tradingview.com/script/B5MWwWad-last-red-low-last-green-high-exit/
- type: indicator
- pine_id: PUB;a2c31cc59b4f49c1bcc4c882c127e06c
- version: 8.0

## Description

This is a good alternative to pivot points and ma lines to find long and short exit points (stop loss prices) for a trade.
When you hear traders say "set the stop loss to the recent swing", this indicator seems to do a reasonable job of finding those.

This script marks 
[list]
[*] the low of the most recent red candle
[*]  the high of the most recent green candle 
[/list] 
in order to help identify a reasonable stop loss exit point for long and short trades.

You can also specify a distance threshold to the stop loss point. 

[b]How to use it.[/b]
[list]
[*]Decide how far from the current price the exit should be (default 1.5%)
[*] Use your chosen trading strategy to identify a long or short entry position
[*] Add a long/short drawing to the close of the trade candle
[*] Set the stop loos of your drawing to the exit line of this indicator
[*] Set the take profit of your drawing using the desired risk to reward ratio
[/list]

[b]Note:[/b] A good rule is that if this indicator does not show a valid exit line, do not enter the trade.
[b]Note:[/b] If the change of a new "last Green High" or the "last Red Low" is below 0.5%, the indicator will keep the previous values

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © carlpwilliams2

//@version=5
indicator("'Last red low / Last green high' exit", overlay=true)

/// copy from this point to add to your strat

/// ****  'Last red low / Last green high' exit indicator by @carlpwilliams2 - https://www.tradingview.com/script/B5MWwWad-last-red-low-last-green-high-exit/
stopLossTarget = input.float(0.5,title="Stop loss target %")
reqChangePerc = input.float(0.1,title="Change % required for new high/low")
showGreenHighs = input.bool(true, title="Show long Exit points", group="Exit points")
showRedLows = input.bool(true, title="Show short Exit points", group="Exit points")

var lowOfLastRed =low
var highOfLastGreen = high
var tpLongPrice = close

candleIsRed = open>close
candleIsGreen = not candleIsRed

changeOfLowPerc = lowOfLastRed>low? ((lowOfLastRed - low)/low)*100 : ((low - lowOfLastRed)/lowOfLastRed) *100
changeOfHighPerc =  highOfLastGreen>high? ((highOfLastGreen - high)/high) *100 :  ((high - highOfLastGreen)/highOfLastGreen) *100

if(candleIsRed and barstate.isconfirmed and (changeOfLowPerc>reqChangePerc or changeOfLowPerc<0))
    lowOfLastRed :=  low

if(candleIsGreen and barstate.isconfirmed and (changeOfHighPerc>reqChangePerc or changeOfHighPerc>0))
    highOfLastGreen := high

distanceToHigh = (highOfLastGreen - close)
distanceToLow  = (close - lowOfLastRed)
distanceToLongExitPercentage = (distanceToLow/close)*100
distanceToShortExitPercentage = (distanceToHigh/highOfLastGreen) * 100


plot(not ta.change(lowOfLastRed) and showGreenHighs and distanceToLongExitPercentage > stopLossTarget ? lowOfLastRed : na, title = "Low of last red", style = plot.style_stepline_diamond, color = distanceToLongExitPercentage > stopLossTarget ? color.red:color.new(color.red,60), linewidth=2)
plot(not ta.change(highOfLastGreen) and showRedLows and distanceToShortExitPercentage > stopLossTarget ? highOfLastGreen : na, title="High of last green", style=plot.style_stepline_diamond, color = distanceToShortExitPercentage > stopLossTarget ? color.green:color.new(color.green,60), linewidth=2)

// ***** end of last red/green indicator
````
