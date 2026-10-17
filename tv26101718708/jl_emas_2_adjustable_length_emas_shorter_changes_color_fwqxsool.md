# JL - EMAs (2 Adjustable Length EMAs, Shorter Changes Color)

- url: https://www.tradingview.com/script/FWQXsOOl-JL-EMAs-2-Adjustable-Length-EMAs-Shorter-Changes-Color/
- type: indicator
- pine_id: PUB;04c182130a094aa08a2bad276936ae07
- version: 1.0

## Description

This indicator has [b]2 user-adjustable EMAs[/b], initially set to 20 and 221 (lengths are based on BPA / Brooks Price Action / Al Brooks methodology).

[b]The faster EMA (20) changes color[/b] from a 'Bullish' color (Blue by default) to a 'Trading Range' color (Black by default) to a 'Bearish' color (Red by default) [b]when there are X number of consecutive closes above or below the shorter / faster EMA[/b] (default input is set to 20).

For example, if there are 3 consecutive closes below the faster EMA (20) then the faster EMA will change color to Red, and vice versa to Blue when there are 3 consecutive closes above the EMA.   

When neither of those conditions is true, the EMA is Black, representing a transition period or small trading range at a minimum.

I hope you find this indicator helpful for your work, take care

## Source Code

````pine
//@version=6
indicator("JL - EMAs", overlay=true)

// Input parameters
ema20_length  = input.int(20, title="EMA 20 Length", minval=1)
ema221_length = input.int(221, title="EMA 221 Length", minval=1)

colorEMA20 = input.bool(true, title="Color 20 EMA")
closeCount = input.int(3, title="Closes Above/Below EMA", minval=1)

bullColor = input.color(color.rgb(0, 124, 212), title="Bull 20 EMA Color")
bearColor = input.color(color.red, title="Bear 20 EMA Color")
neutralColor = input.color(color.black, title="Neutral 20 EMA Color")

ema221Color = input.color(color.rgb(0, 124, 212), title="EMA 221 Color")

// Calculations
ema20  = ta.ema(close, ema20_length)
ema221 = ta.ema(close, ema221_length)

// Close count logic
aboveEMA = close > ema20
belowEMA = close < ema20

bullCondition = math.sum(aboveEMA ? 1 : 0, closeCount) == closeCount
bearCondition = math.sum(belowEMA ? 1 : 0, closeCount) == closeCount

ema20Color =
     colorEMA20 ?
         bullCondition ? bullColor :
         bearCondition ? bearColor :
         neutralColor :
     bullColor

// Plot EMA 20 as a line
plot(ema20, color=ema20Color, linewidth=1, title="EMA 20", offset=0)

// Plot EMA 221 as small circles
plot(ema221, color=ema221Color, style=plot.style_line, title="EMA 221", offset=0)
````
