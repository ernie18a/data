# EMA Ribbon - Anchored

- url: https://www.tradingview.com/script/yPhZzpIg-EMA-Ribbon-Anchored/
- type: indicator
- pine_id: PUB;36c8080eddbd4d40a15f7ef0a69c54b3
- version: 1.0

## Description

nine emas stacked on one chart, from the 5 out to the 600. built for the 4 hour timeframe, works on any.

the ribbon paints green when the fastest ema is above the slowest with a buffer, red when it's below, teal in between. the fills fade from the fast edge to the slow edge so you can see the whole trend structure at a glance instead of reading nine separate lines.

how i use it: after a long downtrend (6 to 12 months), the first time price reclaims the entire stack has historically marked the end of the downtrend or come close, at least on btc, eth and sol. it will not catch bottoms. a full reclaim usually happens 20 to 50% off the low. that's the price of confirmation. what it offers instead is not deploying into a falling knife.

it also isn't a buy signal on its own. price can chop and retest after a reclaim. it just tells you the bleed phase is likely over.

inputs are open, adjust the ema lengths and the buffer however you like. code is open too.
not financial advice. i buy spot and sit on it. this is one input among several.

## Source Code

````pine
//@version=6
indicator("EMA Ribbon - Anchored", overlay=true)

// === INPUTS ===
bullOpacity = input.int(20, "Bull Opacity", minval=0, maxval=80)
bearOpacity = input.int(20, "Bear Opacity", minval=0, maxval=80)
buffer      = input.float(0.5, "Trend Buffer %", minval=0.0, maxval=5.0, step=0.1) / 100



l1 = input.int(5,   "EMA 1 (fastest)")
l2 = input.int(20,  "EMA 2")
l3 = input.int(50,  "EMA 3")
l4 = input.int(100, "EMA 4")
l5 = input.int(150, "EMA 5")
l6 = input.int(200, "EMA 6")
l7 = input.int(300, "EMA 7")
l8 = input.int(450, "EMA 8")
l9 = input.int(600, "EMA 9 (slowest)")

// === EMAs ===
e1 = ta.ema(close, l1)
e2 = ta.ema(close, l2)
e3 = ta.ema(close, l3)
e4 = ta.ema(close, l4)
e5 = ta.ema(close, l5)
e6 = ta.ema(close, l6)
e7 = ta.ema(close, l7)
e8 = ta.ema(close, l8)
e9 = ta.ema(close, l9)

// === TREND STATE ===
bull = e1 > e9 * (1 + buffer)
bear = e1 < e9 * (1 - buffer)

// === COLORS ===
neonGreen = #00ff88
neonRed   = #ff3030
teal      = #00bcd4

baseColor = bull ? neonGreen : bear ? neonRed : teal

// === PLOTS ===
p1 = plot(e1, display=display.none)
p2 = plot(e2, display=display.none)
p3 = plot(e3, display=display.none)
p4 = plot(e4, display=display.none)
p5 = plot(e5, display=display.none)
p6 = plot(e6, display=display.none)
p7 = plot(e7, display=display.none)
p8 = plot(e8, display=display.none)
p9 = plot(e9, display=display.none)

// === RIBBON FILLS ===
// === RIBBON FILLS ===
fill(p1, p2, color=color.new(baseColor, bullOpacity))
fill(p2, p3, color=color.new(baseColor, bullOpacity + 8))
fill(p3, p4, color=color.new(baseColor, bullOpacity + 16))
fill(p4, p5, color=color.new(baseColor, bullOpacity + 24))
fill(p5, p6, color=color.new(baseColor, bullOpacity + 32))
fill(p6, p7, color=color.new(baseColor, bullOpacity + 40))
fill(p7, p8, color=color.new(baseColor, bullOpacity + 45))
fill(p8, p9, color=color.new(baseColor, bullOpacity + 50))

// === PRICE FRINGE ===
pricePlot     = plot(close, display=display.none)
priceInRibbon = (close < e1 and close > e9) or (close > e1 and close < e9)
fringeColor   = priceInRibbon and bull ? color.new(#ff69b4, 55) : priceInRibbon and bear ? color.new(#00bcd4, 55) : bull ? color.new(neonGreen, 85) : color.new(neonRed, 85)

fill(pricePlot, p1, color=fringeColor)
````
