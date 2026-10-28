# Eye Bro MA System [5/20/99/128/225]

- url: https://www.tradingview.com/script/7FtzAu6J/
- type: indicator
- pine_id: PUB;4fba1b5c6017407db403d3bdfb287cdc
- version: 1.0

## Description

眼哥均线战法更新版本

## Source Code

````pine
//@version=6
indicator("Eye Bro MA System [5/20/99/128/225]", overlay=true)

// ============ Inputs ============
lookback       = input.int(3,   title="Break Confirmation Bars", minval=1)
conf_threshold = input.float(1.5, title="Confluence Threshold %", step=0.1)

// ============ Moving Averages ============
ma5   = ta.sma(close, 5)
ma20  = ta.sma(close, 20)
ma99  = ta.sma(close, 99)
ma128 = ta.sma(close, 128)
ma225 = ta.sma(close, 225)
ma285 = ta.sma(close, 285)

plot(ma5,   "MA5",   color.new(color.white, 0),   1)
plot(ma20,  "MA20",  color.new(color.yellow, 0),  1)
plot(ma99,  "MA99",  color.new(color.blue, 0),    2)
plot(ma128, "MA128", color.new(color.orange, 0),  2)
plot(ma225, "MA225", color.new(color.red, 0),     2)
plot(ma285, "MA285", color.new(color.gray, 40),   1)

// ============ Trend (define early so it can drive the lowest bg layer) ============
is_uptrend   = ma5 > ma20 and ma20 > ma99 and close > ma20
is_downtrend = ma5 < ma20 and ma20 < ma99 and close < ma20
trend_bg = is_uptrend   ? color.new(color.green, 95) :
           is_downtrend ? color.new(color.red, 95)   :
                          color.new(color.gray, 95)
bgcolor(trend_bg, title="Trend BG")   // bottom layer; use color.new instead of removed `transp`

// ============ Break detection ============
// "Broken" = price has stayed below the MA for >= `lookback` consecutive bars.
// barssince(close >= ma) counts bars since price was last at/above the MA.
confirmed_below_ma20  = close < ma20  and ta.barssince(close >= ma20)  >= lookback
confirmed_below_ma99  = close < ma99  and ta.barssince(close >= ma99)  >= lookback
confirmed_below_ma128 = close < ma128 and ta.barssince(close >= ma128) >= lookback
confirmed_below_ma225 = close < ma225 and ta.barssince(close >= ma225) >= lookback

// Rising-edge: fire only on the bar the break is first confirmed (replaces the broken crossover(bool, true) idiom)
fire_break_ma20  = confirmed_below_ma20  and not confirmed_below_ma20[1]
fire_break_ma99  = confirmed_below_ma99  and not confirmed_below_ma99[1]
fire_break_ma128 = confirmed_below_ma128 and not confirmed_below_ma128[1]
fire_break_ma225 = confirmed_below_ma225 and not confirmed_below_ma225[1]

plotshape(fire_break_ma20,  title="Break MA20",  style=shape.triangledown, location=location.abovebar, color=color.red,    size=size.small, text="B20")
plotshape(fire_break_ma99,  title="Break MA99",  style=shape.triangledown, location=location.abovebar, color=color.maroon, size=size.small, text="B99")
plotshape(fire_break_ma128, title="Break MA128", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small, text="B128")
plotshape(fire_break_ma225, title="Break MA225", style=shape.xcross,       location=location.abovebar, color=color.red,    size=size.small, text="B225")

// ============ MA Confluence Zone ============
confluence_ma99_128  = math.abs(ma99 - ma128)  / close * 100
confluence_ma128_225 = math.abs(ma128 - ma225) / close * 100
confluence_ma99_225  = math.abs(ma99 - ma225)  / close * 100
is_confluence = confluence_ma99_128 < conf_threshold or confluence_ma128_225 < conf_threshold or confluence_ma99_225 < conf_threshold
bgcolor(is_confluence ? color.new(color.purple, 90) : na, title="MA Confluence Zone")
conf_center = is_confluence ? (ma99 + ma128 + ma225) / 3 : na
plot(conf_center, "Confluence Center", color.new(color.purple, 50), style=plot.style_cross, linewidth=1)

// ============ Stop-loss reference lines (shown only while the MA is broken) ============
plot(confirmed_below_ma20  ? ma20  : na, "SL:MA20",  color.new(color.yellow, 30), style=plot.style_linebr, linewidth=2)
plot(confirmed_below_ma99  ? ma99  : na, "SL:MA99",  color.new(color.blue, 30),   style=plot.style_linebr, linewidth=2)
plot(confirmed_below_ma225 ? ma225 : na, "SL:MA225", color.new(color.red, 30),    style=plot.style_linebr, linewidth=2)

// ============ First-touch bounce detection (only in a downtrend) ============
near_ma99   = math.abs(close - ma99)  / ma99  * 100 < 1.0 and close > ma99  * 0.99
near_ma225  = math.abs(close - ma225) / ma225 * 100 < 1.0 and close > ma225 * 0.99
touch_ma99  = is_downtrend and near_ma99
touch_ma225 = is_downtrend and near_ma225
fire_touch_ma99  = touch_ma99  and not touch_ma99[1]
fire_touch_ma225 = touch_ma225 and not touch_ma225[1]
plotshape(fire_touch_ma99,  title="Touch MA99",  style=shape.circle, location=location.belowbar, color=color.blue, size=size.small, text="T99")
plotshape(fire_touch_ma225, title="Touch MA225", style=shape.circle, location=location.belowbar, color=color.red,  size=size.small, text="T225")

// ============ Chip Exchange Zone (tight range + high volume) ============
volume_avg      = ta.sma(volume, 20)
is_high_vol     = volume > volume_avg * 1.5
price_range_pct = (ta.highest(high, 10) - ta.lowest(low, 10)) / ta.lowest(low, 10) * 100
is_chip_zone    = price_range_pct < 3.0 and is_high_vol
bgcolor(is_chip_zone ? color.new(color.orange, 92) : na, title="Chip Exchange Zone")

// ============ Info Panel ============
var table infoPanel = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    table.cell(infoPanel, 0, 0, "Eye Bro MA", text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 0, timeframe.period, text_color=color.yellow, text_size=size.small)
    table.cell(infoPanel, 0, 1, "MA5",   text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 1, str.tostring(ma5,   format.mintick), text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 0, 2, "MA20",  text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 2, str.tostring(ma20,  format.mintick), text_color=color.yellow, text_size=size.small)
    table.cell(infoPanel, 0, 3, "MA99",  text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 3, str.tostring(ma99,  format.mintick), text_color=color.blue, text_size=size.small)
    table.cell(infoPanel, 0, 4, "MA128", text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 4, str.tostring(ma128, format.mintick), text_color=color.orange, text_size=size.small)
    table.cell(infoPanel, 0, 5, "MA225", text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 5, str.tostring(ma225, format.mintick), text_color=color.red, text_size=size.small)
    trend_text = is_uptrend ? "UP" : is_downtrend ? "DOWN" : "RANGE"
    trend_tc   = is_uptrend ? color.green : is_downtrend ? color.red : color.gray
    table.cell(infoPanel, 0, 6, "Trend", text_color=color.white, text_size=size.small)
    table.cell(infoPanel, 1, 6, trend_text, text_color=trend_tc, text_size=size.small)

// ============ Alerts ============
alertcondition(fire_break_ma20,  title="Break MA20 - Reduce 1/3", message="MA20 broken for the confirmation window. Reduce position by 1/3.")
alertcondition(fire_break_ma99,  title="Break MA99 - Clear",      message="MA99 broken for the confirmation window. Clear or keep 1/3 only.")
alertcondition(fire_break_ma225, title="Break MA225 - Exit All",  message="MA225 broken. Last exit point.")
alertcondition(is_confluence and not is_confluence[1], title="MA Confluence Zone", message="Entering MA confluence zone, watch for breakout.")
alertcondition(fire_touch_ma99,  title="Touch MA99 - Bounce",  message="First touch of MA99, expect bounce.")
alertcondition(fire_touch_ma225, title="Touch MA225 - Bounce", message="First touch of MA225, expect bounce.")
````
