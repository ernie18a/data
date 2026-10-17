# MA Distance % Alert

- url: https://www.tradingview.com/script/4dq791KN-MA-Distance-Alert/
- type: indicator
- pine_id: PUB;6e36e9d2ae8345e1be9d64583102073a
- version: 1.0

## Description

A simple script that places a red dot on the chart when the MA is % away from the price.

I've found the best results on the daily with the settings of 50% away from the 50d MA.

## Source Code

````pine
//@version=6
indicator("MA Distance % Alert", overlay=true)

// Inputs
ma_length = input.int(20, title="MA Length", minval=1)
ma_type = input.string("SMA", title="MA Type", options=["SMA", "EMA", "WMA", "HMA"])
threshold_pct = input.float(50.0, title="Distance Threshold (%)", minval=0.01, step=0.5)
show_ma = input.bool(true, title="Show MA Line")

// Calculate MA
ma = switch ma_type
    "SMA" => ta.sma(close, ma_length)
    "EMA" => ta.ema(close, ma_length)
    "WMA" => ta.wma(close, ma_length)
    "HMA" => ta.hma(close, ma_length)

// Calculate % distance from MA
pct_from_ma = ((close - ma) / ma) * 100

// Conditions
above_threshold = pct_from_ma >= threshold_pct
below_threshold = pct_from_ma <= -threshold_pct

// Plot MA
plot(show_ma ? ma : na, title="MA", color=color.yellow, linewidth=2)

// Plot dots
plotshape(above_threshold, title="Above Threshold", 
     location=location.abovebar, 
     style=shape.circle, 
     size=size.small, 
     color=color.new(color.red, 0))

plotshape(below_threshold, title="Below Threshold", 
     location=location.belowbar, 
     style=shape.circle, 
     size=size.small, 
     color=color.new(color.green, 0))

// Background highlight
bgcolor(above_threshold ? color.new(color.red, 85) : below_threshold ? color.new(color.green, 85) : na, title="Background Highlight")

// Alerts
alertcondition(above_threshold, title="Price Above MA by X%", 
     message="Price is {{pct_from_ma}}% ABOVE the MA (threshold: {{threshold_pct}}%)")
alertcondition(below_threshold, title="Price Below MA by X%", 
     message="Price is {{pct_from_ma}}% BELOW the MA (threshold: {{threshold_pct}}%)")
alertcondition(above_threshold or below_threshold, title="Price X% Away from MA (Either Direction)", 
     message="Price is {{pct_from_ma}}% from the MA")
````
