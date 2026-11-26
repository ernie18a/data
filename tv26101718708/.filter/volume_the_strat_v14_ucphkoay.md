# Volume - The Strat v1.4

- url: https://www.tradingview.com/script/UcPHkOaY-Volume-The-Strat-v1-4/
- type: indicator
- pine_id: PUB;f59c5b17860046809df7bf310df86f29
- version: 1.0

## Description

Volume analysis with The Strat. This is an indicator that shows higher time frame volume bars, coloured to the candle types from The Strat system. This helps with time frame continuity when trading and analysing the price chart in lower time frames.

## Source Code

````pine
//@version=6
indicator(title="Volume - The Strat v1.4", shorttitle="Vol Strat", format=format.percent, precision=2, scale=scale.right)
// The Strat is a strategy created by Rob Smith, from which this indicator is inspired.

// ─────────────────────────────────────────────────
// User Settings
// ─────────────────────────────────────────────────
tf1      = input.timeframe("D",   title="Upper Timeframe", group="Timeframes")
tf2      = input.timeframe("W",   title="Lower Timeframe", group="Timeframes")
lookback = input.int(100, title="Lookback Period", minval=10, maxval=500, group="Settings")

// ─────────────────────────────────────────────────
// Upper timeframe data
// ─────────────────────────────────────────────────
tf1_vol       = request.security(syminfo.tickerid, tf1, volume)
tf1_high      = request.security(syminfo.tickerid, tf1, high)
tf1_low       = request.security(syminfo.tickerid, tf1, low)
tf1_prev_high = request.security(syminfo.tickerid, tf1, high[1])
tf1_prev_low  = request.security(syminfo.tickerid, tf1, low[1])

// ─────────────────────────────────────────────────
// Lower timeframe data
// ─────────────────────────────────────────────────
tf2_vol       = request.security(syminfo.tickerid, tf2, volume)
tf2_high      = request.security(syminfo.tickerid, tf2, high)
tf2_low       = request.security(syminfo.tickerid, tf2, low)
tf2_prev_high = request.security(syminfo.tickerid, tf2, high[1])
tf2_prev_low  = request.security(syminfo.tickerid, tf2, low[1])

// ─────────────────────────────────────────────────
// Strat type → color
// ─────────────────────────────────────────────────
stratColor(h, l, ph, pl) =>
    is_type3  = h > ph and l < pl
    is_type2u = h > ph and l >= pl
    is_type2d = h <= ph and l < pl
    col = is_type3  ? color.orange :
          is_type2u ? color.green  :
          is_type2d ? color.red    :
          color.gray
    col

tf1_col = stratColor(tf1_high, tf1_low, tf1_prev_high, tf1_prev_low)
tf2_col = stratColor(tf2_high, tf2_low, tf2_prev_high, tf2_prev_low)

// ─────────────────────────────────────────────────
// Normalize each series to 0–1 over a lookback
// then map: upper → 0.5 to 1.0 (top half)
//           lower → 0.0 to 0.5 (bottom half)
// ─────────────────────────────────────────────────
tf1_max = ta.highest(tf1_vol, lookback)
tf2_max = ta.highest(tf2_vol, lookback)

tf1_norm = tf1_max > 0 ? (tf1_vol / tf1_max) * 0.5 : 0.0
tf2_norm = tf2_max > 0 ? (tf2_vol / tf2_max) * 0.5 : 0.0

tf1_plot =  tf1_norm + 0.5
tf2_plot = -(tf2_norm + 0.5)

// ─────────────────────────────────────────────────
// Divider lines
// ─────────────────────────────────────────────────
hline(0,    "Midline",   color=color.new(color.white, 60), linestyle=hline.style_solid,  linewidth=1)
hline( 0.5, "Upper top", color=color.new(color.white, 85), linestyle=hline.style_dashed, linewidth=1)
hline(-0.5, "Lower bot", color=color.new(color.white, 85), linestyle=hline.style_dashed, linewidth=1)

// ─────────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────────
plot(tf1_plot, title="Upper TF Volume", style=plot.style_columns, color=tf1_col)
plot(tf2_plot, title="Lower TF Volume", style=plot.style_columns, color=tf2_col)

plot( 0.75, title="Upper label ref", color=color.new(color.white, 100), display=display.none)
plot(-0.75, title="Lower label ref", color=color.new(color.white, 100), display=display.none)
````
