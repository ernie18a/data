# Signal Zone

- url: https://www.tradingview.com/script/eWNTYz39-Signal-Zone/
- type: indicator
- pine_id: PUB;a0589637e57b4556a316a03ca4846d4f
- version: 1.0

## Description

[image]https://www.tradingview.com/x/CgHC0zJT/[/image]
Signal Zone is a simple moving-average crossover indicator that highlights confirmed BUY and CLOSE signals directly on the chart.

The script uses a fast EMA and slow EMA crossover system:
- BUY appears when the fast EMA crosses above the slow EMA.
- CLOSE appears when the fast EMA crosses below the slow EMA.
- Signals only fire on confirmed bars to reduce repaint risk.
- The chart background turns green while a long position is active.
- The chart background turns red while flat/closed.
- Compact BUY and CLOSE labels are plotted directly on the signal bars.
- Alert conditions are included for both BUY and CLOSE signals.

Default settings:
Fast MA: 9 EMA
Slow MA: 21 EMA

This indicator is for visual analysis and alert generation only. It does not place trades automatically.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mkeff

indicator("Signal Zone", overlay=true)

// --- inputs ---
fastLen = input.int(9,  "Fast MA", minval=1)
slowLen = input.int(21, "Slow MA", minval=1)

// --- logic ---
fastMA = ta.ema(close, fastLen)
slowMA = ta.ema(close, slowLen)

var bool longActive = false

buySignal  = barstate.isconfirmed and ta.crossover(fastMA, slowMA) and not longActive
sellSignal = barstate.isconfirmed and ta.crossunder(fastMA, slowMA) and longActive

if buySignal
    longActive := true

if sellSignal
    longActive := false

shortActive = not longActive

// --- background zones ---
bgcolor(longActive  ? color.new(color.green, 85) : na, title="Long Zone")
bgcolor(shortActive ? color.new(color.red,   85) : na, title="Short Zone")

// --- signal labels ---
if buySignal
    label.new(
        bar_index,
        low,
        "BUY",
        style     = label.style_label_up,
        color     = color.new(#00c176, 10),
        textcolor = color.white,
        size      = size.small
    )

if sellSignal
    label.new(
        bar_index,
        high,
        "CLOSE",
        style     = label.style_label_down,
        color     = color.new(#ff3b3b, 10),
        textcolor = color.white,
        size      = size.small
    )

// --- plotshapes for alerts ---
plotshape(
     buySignal,
     title    = "BUY Signal",
     location = location.belowbar,
     style    = shape.triangleup,
     color    = color.new(#00c176, 10),
     size     = size.tiny
)

plotshape(
     sellSignal,
     title    = "CLOSE Signal",
     location = location.abovebar,
     style    = shape.triangledown,
     color    = color.new(#ff3b3b, 10),
     size     = size.tiny
)

// --- MA lines ---
plot(fastMA, title="Fast MA", color=color.aqua, linewidth=1)
plot(slowMA, title="Slow MA", color=color.orange, linewidth=1)

// --- alerts ---
alertcondition(buySignal,  title="BUY",   message="BUY signal fired")
alertcondition(sellSignal, title="CLOSE", message="CLOSE signal fired")
````
