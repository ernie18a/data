<!-- tradingview-pine-id: PUB;b8zUQXQCYsCAdHLsgKXeBDoRwFGpPSsQ -->
<!-- tradingviewscripts-format: 1 -->
# Day Play Ace Spectrum

Source: https://www.tradingview.com/script/I4ifUwSu-Daily-Play-Ace-Spectrum/

## Description

So the idea of the Daily Play Ace Spectrum is to extend the Ace Spectrum.
By exposing more parameters, making a variation of the Ace Spectrum which is more configurable.

The idea is this makes the Daily Play Ace Spectrum more suitable for use on shorter (hourly and minute) time scales.

These specific parameters exposed still maintain the original form of the original Ace Spectrum, but loosen up the hard coded assumptions of the original indicator.
By exposing more parameters this now makes the Daily Ace Spectrum more sensitive to input.
Meaning the parameters you choose are important and will set the characteristic reaction of the indicator to the series you give it.

This presents a trade-off, the simplicity of the original indicator is sacrificed.
But what's gained is a more comprehensive indicator that now needs more careful parameter adjustment.

Related to the Ace Spectrum: https://www.tradingview.com/script/XbJzyh4X-Ace-Spectrum/

---

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
