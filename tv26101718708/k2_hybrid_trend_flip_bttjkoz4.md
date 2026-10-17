# K2 Hybrid Trend Flip

- url: https://www.tradingview.com/script/BTtjKoZ4-K2-Hybrid-Trend-Flip/
- type: indicator
- pine_id: PUB;3163fa57e9e84c09b419d78e16ffc419
- version: 2.0

## Description

K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends. K2 Hybrid Trend Flip in progress to catch up and down trends.

## Source Code

````pine
//@version=6
indicator("NW Hybrid Trend Flip [Combine Core]", overlay=true, max_bars_back=500)

// Inputs
windowSize = input.int(100, "Window Size", minval=1)
bandwidth = input.float(8.0, "Bandwidth", minval=0.0001, step=0.1)
envelopeWidth = input.float(3.0, "Envelope Width", minval=0.0, step=0.1)
src = input.source(close, "Source")
kernelPower = input.float(2.0, "Kernel power", minval=0.1, step=0.1)
kernelDenominator= input.float(2.0, "Kernel denominator", minval=0.1, step=0.1)
showBands = input.bool(true, "Show Envelope")
showSignals = input.bool(true, "Show Flip Signals")
showBg = input.bool(false, "Background Trend")

// NW-style weighted estimate
nw_estimate(_src, _len, _bw, _pow, _den) =>
    float num = 0.0
    float den = 0.0
    for i = 0 to _len - 1
        dist = math.abs(i) / _bw
        w = 1.0 / math.pow(1.0 + math.pow(dist, _pow) / _den, _den)
        num += _src[i] * w
        den += w
    den != 0.0 ? num / den : na

mid = nw_estimate(src, windowSize, bandwidth, kernelPower, kernelDenominator)

// Basic volatility envelope from residuals
resid = math.abs(src - mid)
dev = ta.sma(resid, math.max(1, int(math.round(windowSize / 5.0))))
upper = mid + envelopeWidth * dev
lower = mid - envelopeWidth * dev

// Middle line state change
bull = mid > mid[1]
bear = mid < mid[1]

bullFlip = bull and not bull[1]
bearFlip = bear and not bear[1]

// Colors
midColor = bull ? color.lime : color.red
plot(mid, "Middle Line", color=midColor, linewidth=2)
plot(showBands ? upper : na, "Upper Band", color=color.new(color.lime, 30))
plot(showBands ? lower : na, "Lower Band", color=color.new(color.red, 30))

fill(plot(showBands ? upper : na, display=display.none),
     plot(showBands ? lower : na, display=display.none),
     color=color.new(color.gray, 90))

bgcolor(showBg ? (bull ? color.new(color.green, 90) : color.new(color.red, 90)) : na)

plotshape(showSignals and bullFlip, title="Bull Flip", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="UP")
plotshape(showSignals and bearFlip, title="Bear Flip", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="DN")

alertcondition(bullFlip, title="NW Bull Flip", message="NW Hybrid Trend Flip: middle line flipped bullish.")
alertcondition(bearFlip, title="NW Bear Flip", message="NW Hybrid Trend Flip: middle line flipped bearish.")
````
