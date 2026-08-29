<!-- tradingview-pine-id: PUB;a4de5c21e4c74c33b91b8198d947c25e -->
<!-- tradingviewscripts-format: 1 -->
# Chop Detector

Source: https://www.tradingview.com/script/bZeU0zdn-Chop-Detector/

## Description

Colours each bar by how choppy the market is right now, so you can see at a glance when conditions are bad for tight stops.

What it measures:

Wick size compared to body size — long wicks with small bodies means price is spiking around without going anywhere
Averaged over a lookback window so one odd bar doesn't swing the reading
Blends in the bars either side of each one, so the reading reflects the local area, not a single candle
Watches for big bodies — when a candle's body outgrows the recent wicks, that's a breakout, and the reading drops fast to show conditions have changed

How to read it

Lime — clean, directional movement, price is going somewhere
Yellow to orange — getting messier, be careful
Red — choppy, wicks are dominating
Black — very choppy, worst conditions

When to use it:

Before entering, to check whether current conditions suit a tight stop
To decide if it's worth trading a session at all
Works on any timeframe, but intraday charts give the clearest signal

---

## Source Code

````pine
//@version=6
indicator("Chop Detector", overlay = false)

len     = input.int(20, "Smoothing lookback")
center  = input.bool(true, "Center the plot")
wCenter = input.float(0.5,  "Center weight", step = 0.05)
wNear   = input.float(0.25, "Adjacent weight", step = 0.05)
wFar    = input.float(0.10, "Outer weight", step = 0.05)

useBrk  = input.bool(true, "Breakout damping")
w5      = input.float(0.7, "Weight on last 5 wicks", step = 0.05)
brkTrig = input.float(1.0, "Trigger: body / wick ref", step = 0.1)
brkStr  = input.float(0.5, "Damping strength", step = 0.05)
brkHold = input.int(4, "Hold bars")
smooth  = input.int(2, "Output smoothing")

limeThr  = input.float(0.53, "Lime below")
loThr    = input.float(0.53, "Yellow from")
hiThr    = input.float(0.95, "Red at")
blackThr = input.float(1.00, "Black above")

wick = (high - math.max(open, close)) + (math.min(open, close) - low)
body = math.abs(close - open)
raw  = ta.sma(wick, len) / ta.sma(body, len)

num  = raw[2] * wCenter + (raw[1] + raw[3]) * wNear + (raw[0] + raw[4]) * wFar
den  = wCenter + 2 * wNear + 2 * wFar
base = num / den

wickRef = ta.sma(wick, 5) * w5 + ta.sma(wick, 10) * (1 - w5)
brk     = wickRef > 0 ? body / wickRef : 0
brkNow  = math.max(brk - brkTrig, 0)
brkMax  = ta.highest(brkNow, brkHold)

damp = useBrk ? 1 / (1 + brkStr * brkMax) : 1
v    = ta.sma(base * damp, smooth)

t    = math.min(math.max((v - loThr) / (hiThr - loThr), 0), 1)
grad = t < 0.5 ? color.from_gradient(t, 0, 0.5, #1D9E75, #EF9F27) : color.from_gradient(t, 0.5, 1, #EF9F27, #E24B4A)
col  = v > blackThr ? #000000 : v < limeThr ? #97C459 : grad

plot(v, "Chop", color = col, style = plot.style_columns, linewidth = 3, offset = center ? -2 : 0)
hline(blackThr, color = color.new(#000000, 60))
hline(hiThr,    color = color.new(color.red, 60))
hline(loThr,    color = color.new(color.green, 60))
hline(limeThr,  color = color.new(#97C459, 60))
````
