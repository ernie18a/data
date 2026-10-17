# Distribution Day & Follow-Through Day

- url: https://www.tradingview.com/script/VR34XsHj-Distribution-Day-Follow-Through-Day/
- type: indicator
- pine_id: PUB;c7ccd6b43df64ab784a81602c7168301
- version: 2.0

## Description

Distribution Day & Follow-Through Day
when stock go/ down 1.5% and volumn > last day

## Source Code

````pine
//@version=6
// Marks distribution day and follow-through day
indicator('Distribution Day & Follow-Through Day', overlay = true)

// Calculate percentage change from previous close
price_change_pct = (close - close[1]) / close[1]

// Calculate price and volume conditions
// CANSLIM typical Distribution: price down (often > 0.2% or just negative) on higher volume.
// Adjust the -0.015 (-1.5%) threshold if it's too strict for your daily timeframe.
is_down_bar   = price_change_pct <= -0.015
is_up_bar     = price_change_pct >= 0.015
// is_volume_up  = volume > volume[1]
is_volume_up  = true

// Determine signal days
is_distribution  = is_down_bar and is_volume_up
is_followthrough = is_up_bar and is_volume_up

// Plotting the pointers
plotshape(series = is_distribution,  title = "Distribution Day",  style = shape.triangledown, location = location.abovebar, color = color.red,   size = size.normal)
plotshape(series = is_followthrough, title = "Follow-Through Day", style = shape.triangleup,   location = location.belowbar, color = color.green, size = size.normal)
````
