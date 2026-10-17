# IMBA Shyngysxan

- url: https://www.tradingview.com/script/mFEBm2ed-imba-shyngysxan/
- type: indicator
- pine_id: PUB;ef3fa948cde14759a6527bdb0d2c56a9
- version: 1.0

## Description

imba mg hfjy f
 kkjgk g   ;, lml ,l;,l; ,l;l;njk bjhbhvghfgcfgcfxyhvhbx;;

## Source Code

````pine
//@version=5
indicator("IMBA Shyngysxan", overlay=true)

tolerance = input.float(0.1, step=0.01)
no_shadow_threshold = input.float(0.001, step=0.0001)

prev_bullish = close[1] > open[1]
current_bearish = close < open
open_matches_prev_close = math.abs(open - close[1]) <= tolerance
upper_shadow = high - math.max(open, close)
prev_upper_shadow = high[1] - math.max(open[1], close[1])
longer_upper_shadow = upper_shadow > prev_upper_shadow
signal_upper = prev_bullish and current_bearish and open_matches_prev_close and longer_upper_shadow

prev_bearish = close[1] < open[1]
current_bullish = close > open
open_matches_prev_close_rev = math.abs(open - close[1]) <= tolerance
lower_shadow = math.min(open, close) - low
prev_lower_shadow = math.min(open[1], close[1]) - low[1]
longer_lower_shadow = lower_shadow > prev_lower_shadow
signal_lower = prev_bearish and current_bullish and open_matches_prev_close_rev and longer_lower_shadow

no_upper_shadow = upper_shadow <= no_shadow_threshold
no_lower_shadow = lower_shadow <= no_shadow_threshold

plotshape(no_upper_shadow, location=location.abovebar, style=shape.circle, color=color.orange, size=size.tiny)
plotshape(no_lower_shadow, location=location.belowbar, style=shape.circle, color=color.orange, size=size.tiny)
````
