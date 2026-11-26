# Acceleration + Wyckoff (Balanced) v6

- url: https://www.tradingview.com/script/hvCk1Dqt-Acceleration-Wyckoff-Balanced-v6/
- type: indicator
- pine_id: PUB;544cc26c9c104517a053392bb6b271e6
- version: 1.0

## Description

Hey,

I created this indicator with GROK.

I welcome all feedback, as I really don't know what i'm doing lol

Here is a summary of what I'm trying to achieve....

This is a custom momentum and acceleration indicator that combines Stan Druckenmiller’s second-derivative concept with Wyckoff Method principles. It helps traders identify potential turning points by measuring not just momentum, but the rate of change of momentum (acceleration).

It is designed to be more readable and practical than traditional Rate of Change (ROC) indicators, while providing actionable Wyckoff-style signals (Springs and Upthrusts).

[b]Benefits[/b]

Early Reversal Detection: By focusing on acceleration (not just price or basic momentum), it can highlight potential turning points earlier than many standard indicators.
Wyckoff + Modern TA Hybrid: Combines classic Wyckoff concepts (Springs & Upthrusts) with Druckenmiller-style second-derivative thinking.
Flexible Across Assets: Works well on both individual stocks (e.g. RRL) and commodities (e.g. Gold).
Customizable: Users can adjust sensitivity, enable/disable volume filtering, and choose display styles.
Actionable Signals: Clear visual markers (green/red triangles) make it easy to spot potential high-probability setups.

[b]Best Use Cases[/b]

Daily charts for swing trading and short-term reversals
Weekly charts for identifying larger structural shifts
Trending markets (especially useful on Gold and resource stocks)
Identifying exhaustion points in both uptrends and downtrends
Combining with other tools (volume, support/resistance, or your existing indicators)

[b]In Summary[/b]
This indicator gives you a clearer view of momentum strength and acceleration while adding Wyckoff-inspired reversal signals. It solves common issues with traditional momentum indicators (poor scaling and late signals) and provides a practical, visual way to spot potential Springs and Upthrusts with adjustable sensitivity.

## Source Code

````pine
//@version=6
indicator(title="Acceleration + Wyckoff (Balanced) v6", 
          shorttitle="Accel + Wyckoff v6", 
          overlay=false, format=format.price, precision=2)

// === INPUTS ===
mom_length           = input.int(10, "Momentum Length", minval=1, group="Core")
accel_length         = input.int(5,  "Acceleration Length", minval=1, group="Core")
src                  = input.source(close, "Source", group="Core")

show_mom             = input.bool(true, "Show Momentum Line", group="Display")
show_accel           = input.bool(true, "Show Acceleration", group="Display")
histogram_mode       = input.bool(false, "Histogram Mode", group="Display")
show_on_price        = input.bool(false, "Show Acceleration on Price Chart", group="Display")

use_vol_confirmation = input.bool(false, "Use Volume Confirmation on Springs", group="Signals")
spring_length        = input.int(10, "Spring/Upthrust Lookback", minval=5, group="Signals")
min_accel_flip       = input.float(0.12, "Min Acceleration Strength", minval=0, step=0.05, group="Signals")
vol_ma_length        = input.int(20, "Volume MA Length", minval=5, group="Signals")

// === CALCULATIONS ===
mom   = ta.mom(src, mom_length)
accel = ta.mom(mom, accel_length)
vol_avg = ta.sma(volume, vol_ma_length)

// === SPRING DETECTION (Relaxed) ===
is_swing_low    = ta.lowest(low, spring_length) == low
strong_accel_up = accel > min_accel_flip

low_volume_spring = volume < vol_avg * 1.3

potential_spring = if use_vol_confirmation
    is_swing_low and strong_accel_up and low_volume_spring
else
    is_swing_low and strong_accel_up

// === UPTHRUST DETECTION (Relaxed) ===
is_swing_high     = ta.highest(high, spring_length) == high
strong_accel_down = accel < -min_accel_flip

potential_upthrust = is_swing_high and strong_accel_down

// === PLOTTING ===
mom_color = color.new(color.blue, 0)
accel_col = accel > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
plot_style = histogram_mode ? plot.style_histogram : plot.style_line

plot(mom, "Momentum", color=mom_color, linewidth=2, display=show_mom ? display.all : display.none)
plot(accel, "Acceleration", color=accel_col, style=plot_style, linewidth=2, display=show_accel ? display.all : display.none)

hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)

plotshape(potential_spring,  title="Spring", location=location.belowbar, 
          color=color.green, style=shape.triangleup, size=size.normal)

plotshape(potential_upthrust, title="Upthrust", location=location.abovebar, 
          color=color.red, style=shape.triangledown, size=size.normal)

plot(show_on_price ? accel : na, "Accel on Price", color=accel_col, linewidth=2)
````
