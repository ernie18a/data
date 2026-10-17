# Rainbow MA Ribbon AZI

- url: https://www.tradingview.com/script/K2E4JfvB/
- type: indicator
- pine_id: PUB;17a58ad470414b9fab94d75e679bcedb
- version: 1.0

## Description

Rainbow MA usalo como mejor lo veas, varias emmas guian intencion

## Source Code

````pine
//@version=5
indicator("Rainbow MA Ribbon", overlay=true)

// Inputs
len1 = input.int(5, "MA 1")
len2 = input.int(8, "MA 2")
len3 = input.int(13, "MA 3")
len4 = input.int(21, "MA 4")
len5 = input.int(34, "MA 5")
len6 = input.int(55, "MA 6")
len7 = input.int(89, "MA 7")
len8 = input.int(144, "MA 8")
len9 = input.int(200, "MA 9")
len10 = input.int(233, "MA 10")

// MAs
ma1  = ta.ema(close, len1)
ma2  = ta.ema(close, len2)
ma3  = ta.ema(close, len3)
ma4  = ta.ema(close, len4)
ma5  = ta.ema(close, len5)
ma6  = ta.ema(close, len6)
ma7  = ta.ema(close, len7)
ma8  = ta.ema(close, len8)
ma9  = ta.ema(close, len9)
ma10 = ta.ema(close, len10)

// Plot
p1  = plot(ma1,  color=color.new(#ff0000, 0), linewidth=1)
p2  = plot(ma2,  color=color.new(#ff3300, 0), linewidth=1)
p3  = plot(ma3,  color=color.new(#ff6600, 0), linewidth=1)
p4  = plot(ma4,  color=color.new(#ff9900, 0), linewidth=1)
p5  = plot(ma5,  color=color.new(#ffcc00, 0), linewidth=1)
p6  = plot(ma6,  color=color.new(#99cc00, 0), linewidth=1)
p7  = plot(ma7,  color=color.new(#00aaff, 0), linewidth=1)
p8  = plot(ma8,  color=color.new(#0055ff, 0), linewidth=1)
p9  = plot(ma9,  color=color.new(#4400ff, 0), linewidth=1)
p10 = plot(ma10, color=color.new(#8800ff, 0), linewidth=1)

// Fill entre cada par con transparencia 80
fill(p1,  p2,  color=color.new(#ff0000, 80))
fill(p2,  p3,  color=color.new(#ff3300, 80))
fill(p3,  p4,  color=color.new(#ff6600, 80))
fill(p4,  p5,  color=color.new(#ff9900, 80))
fill(p5,  p6,  color=color.new(#ffcc00, 80))
fill(p6,  p7,  color=color.new(#99cc00, 80))
fill(p7,  p8,  color=color.new(#00aaff, 80))
fill(p8,  p9,  color=color.new(#0055ff, 80))
fill(p9,  p10, color=color.new(#8800ff, 80))
````
