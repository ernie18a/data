# Daily Play Ace Spectrum

- url: https://www.tradingview.com/script/I4ifUwSu-Daily-Play-Ace-Spectrum/
- type: indicator
- pine_id: PUB;b8zUQXQCYsCAdHLsgKXeBDoRwFGpPSsQ
- version: 1.0

## Description

So the idea of the [b]Daily Play Ace Spectrum[/b] is to extend the [b]Ace Spectrum[/b].
By exposing more parameters, making a variation of the [b]Ace Spectrum[/b] which is more configurable.

The idea is this makes the [b]Daily Play Ace Spectrum[/b] more suitable for use on shorter (hourly and minute) time scales.

These specific parameters exposed still maintain the [b]original form[/b] of the original Ace Spectrum, but [b]loosen up the hard coded assumptions[/b] of the original indicator.
By exposing more parameters this now makes the Daily Ace Spectrum more sensitive to input.
Meaning the [b]parameters you choose are important[/b] and will set the [b]characteristic reaction of the indicator[/b] to the series you give it.

This presents a trade-off, the simplicity of the original indicator is sacrificed.
But what's gained is a [b]more comprehensive indicator[/b] that now needs [b]more careful parameter adjustment[/b].

Related to the Ace Spectrum: https://www.tradingview.com/script/XbJzyh4X-Ace-Spectrum/

## Source Code

````pine
//@version=4
study("Day Play Ace Spectrum", overlay=true)

n = input(120)

a = input(18)
b = input(9)

s = input(50)
t = input(4)

for i = 1 to n
    line.new(bar_index[i*a], open[i*a], bar_index[i*b], open[i*b], xloc.bar_index, extend.right, color.new(color.blue, 90), line.style_solid, (i/(n/s))+t)
````
