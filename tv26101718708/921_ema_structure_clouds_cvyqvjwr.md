# 9/21 EMA Structure Clouds

- url: https://www.tradingview.com/script/CvyqVjWr-9-21-EMA-Structure-Clouds/
- type: indicator
- pine_id: PUB;5f5a55bbec3f460087e4f76aadf4c17c
- version: 2.0

## Description

9/21 EMA Structure Clouds - EMA of high / EMA of close / EMA of low setup

## Source Code

````pine
//@version=5
indicator("9/21 EMA + 50/100/200 SMA Clouds", overlay=true)

// --- Lengths ---
shortLen = input.int(9,   "9 EMA / Cloud",  group="EMA Clouds")
longLen  = input.int(21,  "21 EMA / Cloud", group="EMA Clouds")

show50  = input.bool(true, "Show 50 SMA Cloud",  group="SMA Clouds")
show100 = input.bool(true, "Show 100 SMA Cloud", group="SMA Clouds")
show200 = input.bool(true, "Show 200 SMA Cloud", group="SMA Clouds")

// --- 21 EMA structure ---
emaHigh21  = ta.ema(high,  longLen)
emaClose21 = ta.ema(close, longLen)
emaLow21   = ta.ema(low,   longLen)

// --- 9 EMA structure ---
emaHigh9  = ta.ema(high,  shortLen)
emaClose9 = ta.ema(close, shortLen)
emaLow9   = ta.ema(low,   shortLen)

// --- SMA structures ---
sma50H  = ta.sma(high, 50),  sma50C  = ta.sma(close, 50),  sma50L  = ta.sma(low, 50)
sma100H = ta.sma(high, 100), sma100C = ta.sma(close, 100), sma100L = ta.sma(low, 100)
sma200H = ta.sma(high, 200), sma200C = ta.sma(close, 200), sma200L = ta.sma(low, 200)

// --- 21 EMA cloud (gray) ---
high21Plot = plot(emaHigh21,  "21 EMA (high)",  color=color.new(color.gray, 60))
mid21Plot  = plot(emaClose21, "21 EMA (close)", color=color.new(color.gray, 20), linewidth=1)
low21Plot  = plot(emaLow21,   "21 EMA (low)",   color=color.new(color.gray, 60))
fill(high21Plot, low21Plot, color=color.new(color.gray, 88), title="21 Cloud")

// --- 9 EMA cloud (orange) ---
high9Plot = plot(emaHigh9,  "9 EMA (high)",  color=color.new(color.orange, 60))
mid9Plot  = plot(emaClose9, "9 EMA (close)", color=color.new(color.orange, 10), linewidth=1)
low9Plot  = plot(emaLow9,   "9 EMA (low)",   color=color.new(color.orange, 60))
fill(high9Plot, low9Plot, color=color.new(color.orange, 85), title="9 Cloud")

// --- 50 SMA cloud (blue) ---
high50Plot = plot(show50 ? sma50H : na, "50 SMA (high)",  color=color.new(color.blue, 70))
mid50Plot  = plot(show50 ? sma50C : na, "50 SMA (close)", color=color.new(color.blue, 20), linewidth=2)
low50Plot  = plot(show50 ? sma50L : na, "50 SMA (low)",   color=color.new(color.blue, 70))
fill(high50Plot, low50Plot, color=color.new(color.blue, 90), title="50 Cloud")

// --- 100 SMA cloud (purple) ---
high100Plot = plot(show100 ? sma100H : na, "100 SMA (high)",  color=color.new(color.purple, 70))
mid100Plot  = plot(show100 ? sma100C : na, "100 SMA (close)", color=color.new(color.purple, 20), linewidth=2)
low100Plot  = plot(show100 ? sma100L : na, "100 SMA (low)",   color=color.new(color.purple, 70))
fill(high100Plot, low100Plot, color=color.new(color.purple, 92), title="100 Cloud")

// --- 200 SMA cloud (red) ---
high200Plot = plot(show200 ? sma200H : na, "200 SMA (high)",  color=color.new(color.red, 70))
mid200Plot  = plot(show200 ? sma200C : na, "200 SMA (close)", color=color.new(color.red, 20), linewidth=2)
low200Plot  = plot(show200 ? sma200L : na, "200 SMA (low)",   color=color.new(color.red, 70))
fill(high200Plot, low200Plot, color=color.new(color.red, 92), title="200 Cloud")
````
