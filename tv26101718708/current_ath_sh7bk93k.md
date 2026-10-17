# Current ATH

- url: https://www.tradingview.com/script/sH7bk93k-Current-ATH/
- type: indicator
- pine_id: PUB;b94f09ec9c3947909082adaa0c169abf
- version: 1.0

## Description

Plots a horizontal line at the current all time high

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AHoboWithAStick

//@version=6
indicator("Current ATH", overlay=true)

// Track ATH across all bars
ath = ta.highest(high, bar_index + 1)

// Plot a horizontal line at the ATH
plot(ath, title="Current ATH", color=color.new(color.white, 0), linewidth=1, style=plot.style_line)

// Draw label at the ATH
if barstate.islast
    label.new(
        x=bar_index,
        y=ath,
        text="ATH: " + str.tostring(ath, format.mintick),
        color=color.white,
        style=label.style_label_left,
        size=size.normal
    )

plot(close)
````
