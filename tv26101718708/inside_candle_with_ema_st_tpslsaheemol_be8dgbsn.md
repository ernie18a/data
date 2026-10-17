# Inside Candle with EMA +ST +TP/SL@Saheemol

- url: https://www.tradingview.com/script/bE8dgbSN-Inside-Candle-with-EMA-ST-TP-SL-Saheemol/
- type: indicator
- pine_id: PUB;38499e42e930482ea5eb572aa916c3a2
- version: 1.0

## Description

Inside Candle Breakout with EMA, SuperTrend & Auto TP/SL

This indicator combines the power of the Inside Candle breakout pattern, EMA trend analysis, and SuperTrend confirmation to identify high-probability breakout opportunities while automatically plotting trade management levels.

Key Features

✅ Detects valid Mother-Daughter (Inside Candle) formations using customizable body-size filters.

✅ Plots EMA 9, EMA 21, and EMA 200 to help visualize market trend and structure.

✅ Uses SuperTrend confirmation to filter false breakouts:

Buy signals only when SuperTrend is bullish.
Sell signals only when SuperTrend is bearish.

✅ Automatically identifies breakout levels from the Mother Candle's high and low.

✅ Draws:

Entry zone
Stop Loss (SL)
Take Profit 1 (TP1)
Take Profit 2 (TP2)

using user-configurable Risk ratios.

✅ Highlights Inside Candle setups and displays visual breakout signals directly on the chart.

✅ Includes alert conditions for automated notifications.

How It Works
The indicator searches for a strong Mother Candle followed by a valid Inside Candle.
The Mother Candle's high and low become the breakout levels.
A trade signal is generated only when price breaks out of the Mother Candle range and the SuperTrend agrees with the direction.
TP1, TP2, and SL levels are automatically calculated based on the Mother Candle range.
Best Use Cases
Intraday trading
Swing trading
Breakout strategies
Trend-following systems
Forex, Stocks, Crypto, and Indices

This indicator is designed to help traders quickly identify consolidation breakouts while maintaining disciplined risk management through predefined entry, target, and stop-loss zones.

Disclaimer: This script is for educational and informational purposes only and does not constitute financial advice. Trading involves risk, and users should perform their own analysis and risk management before making any trading decisions.

## Source Code

````pine
//@version=6
indicator("Inside Candle with EMA + Breakout TP/SL + SuperTrend Filter@Saheemol", 'IC+EMA@Saheemol',overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//==================== EMA ====================
ema9_length = input.int(9, "EMA 9 Length")
ema21_length = input.int(21, "EMA 21 Length")
ema200_length = input.int(200, "EMA 200 Length")
ema9_color = input.color(color.blue, "EMA 9 Color")
ema21_color = input.color(color.red, "EMA 21 Color")
ema200_color = input.color(color.black, "EMA 200 Color")

ema9 = ta.ema(close, ema9_length)
ema21 = ta.ema(close, ema21_length)
ema200 = ta.ema(close, ema200_length)

plot(ema9, "EMA 9", ema9_color, linewidth=2)
plot(ema21, "EMA 21", ema21_color, linewidth=2)
plot(ema200, "EMA 200", ema200_color, linewidth=4)

//==================== SUPERTREND ====================
st_atrPeriod = input.int(10, "SuperTrend ATR Period")
st_factor = input.float(2.0, "SuperTrend Factor", step=0.1)

[supertrend, st_direction] = ta.supertrend(st_factor, st_atrPeriod)

plot(supertrend, "SuperTrend", st_direction < 0 ? color.green : color.red, linewidth=2)

st_bullish = st_direction < 0
st_bearish = st_direction > 0

//==================== SETTINGS ====================
mother_body_ratio_threshold = input.float(60, "Mother Candle Body Ratio (%)", minval=0, maxval=100) / 100

daughter_body_ratio_threshold = input.float(50, "Daughter Candle Body Ratio Maximum (%)", minval=0, maxval=100) / 100

daughter_highlight_color = input.color(color.new(#000000, 0), "Daughter Highlight")
line_length = input.int(20, "Mother Line Length", minval=5)

tp1_rr = input.float(1.5, "TP1 RR", minval=0.1, step=0.1)
tp2_rr = input.float(3.0, "TP2 RR", minval=0.1, step=0.1)
box_length = input.int(10, "Box Length", minval=5)

entry_box_color = input.color(color.new(color.blue,85), "Entry Box")
tp1_box_color = input.color(color.new(color.green,85), "TP1 Box")
tp2_box_color = input.color(color.new(color.lime,85), "TP2 Box")
sl_box_color = input.color(color.new(color.red,85), "SL Box")

//==================== FUNCTIONS ====================
get_body_ratio(o,c,h,l) =>
    body = math.abs(c-o)
    rng = h-l
    rng > 0 ? body/rng : 0.0

//==================== PATTERN ====================
is_valid_mother = get_body_ratio(open[1], close[1], high[1], low[1]) >= mother_body_ratio_threshold

daughter_body_ratio = get_body_ratio(open, close, high, low)

is_daughter_inside = high <= high[1] and low >= low[1]

is_valid_daughter = daughter_body_ratio <= daughter_body_ratio_threshold

is_daughter = is_daughter_inside and is_valid_daughter

var float mother_high = na
var float mother_low = na
var int mother_bar = na
var bool setup_active = false
var bool breakout_done = false

if is_valid_mother and is_daughter and barstate.isconfirmed
    mother_high := high[1]
    mother_low := low[1]
    mother_bar := bar_index[1]
    setup_active := true
    breakout_done := false

barcolor(is_valid_mother and is_daughter ? daughter_highlight_color : na)

//==================== MOTHER LINES ====================
var line highLine = na
var line lowLine = na

if is_valid_mother and is_daughter and barstate.isconfirmed
    highLine := line.new(
         mother_bar,
         mother_high,
         mother_bar + line_length,
         mother_high,
         color=color.green,
         width=2)

    lowLine := line.new(
         mother_bar,
         mother_low,
         mother_bar + line_length,
         mother_low,
         color=color.red,
         width=2)
//EMA200 Validation

//==================== BREAKOUT ====================
buy_condition = setup_active and not breakout_done and close > mother_high and st_bullish //and close > ema200
sell_condition = setup_active and not breakout_done and close < mother_low and st_bearish //and close < ema200

//==================== BUY ====================
if buy_condition
    entry = mother_high
    sl = mother_low
    risk = entry - sl

    tp1 = entry + risk * tp1_rr
    tp2 = entry + risk * tp2_rr

    box.new(bar_index, entry + syminfo.mintick, bar_index + box_length, entry - syminfo.mintick, bgcolor=entry_box_color, border_color=color.blue)
    box.new(bar_index, tp1, bar_index + box_length, entry, bgcolor=tp1_box_color, border_color=color.green)
    box.new(bar_index, tp2, bar_index + box_length, tp1, bgcolor=tp2_box_color, border_color=color.lime)
    box.new(bar_index, entry, bar_index + box_length, sl, bgcolor=sl_box_color, border_color=color.red)

    label.new(bar_index + box_length, entry, "ENTRY", color=color.blue, textcolor=color.white, size=size.tiny)
    label.new(bar_index + box_length, tp1, "TP1", color=color.green, textcolor=color.white, size=size.tiny)
    label.new(bar_index + box_length, tp2, "TP2", color=color.lime, textcolor=color.black, size=size.tiny)
    label.new(bar_index + box_length, sl, "SL", color=color.red, textcolor=color.white, size=size.tiny)

    breakout_done := true
    setup_active := false

//==================== SELL ====================
if sell_condition
    entry = mother_low
    sl = mother_high
    risk = sl - entry

    tp1 = entry - risk * tp1_rr
    tp2 = entry - risk * tp2_rr

    box.new(bar_index, sl, bar_index + box_length, entry, bgcolor=sl_box_color, border_color=color.red)
    box.new(bar_index, entry, bar_index + box_length, tp1, bgcolor=tp1_box_color, border_color=color.green)
    box.new(bar_index, tp1, bar_index + box_length, tp2, bgcolor=tp2_box_color, border_color=color.lime)
    box.new(bar_index, entry + syminfo.mintick, bar_index + box_length, entry - syminfo.mintick, bgcolor=entry_box_color, border_color=color.blue)

    label.new(bar_index + box_length, entry, "ENTRY", color=color.blue, textcolor=color.white, size=size.tiny)
    label.new(bar_index + box_length, tp1, "TP1", color=color.green, textcolor=color.white, size=size.tiny)
    label.new(bar_index + box_length, tp2, "TP2", color=color.lime, textcolor=color.black, size=size.tiny)
    label.new(bar_index + box_length, sl, "SL", color=color.red, textcolor=color.white, size=size.tiny)

    breakout_done := true
    setup_active := false

//==================== VISUALS ====================
plotshape(buy_condition, title="Buy Signal", location=location.belowbar, style=shape.triangleup, color=color.green, size=size.small)
plotshape(sell_condition, title="Sell Signal", location=location.abovebar, style=shape.triangledown, color=color.red, size=size.small)

plot(mother_high, "Mother High", color.new(color.green,50), linewidth=1, style=plot.style_circles)
plot(mother_low, "Mother Low", color.new(color.red,50), linewidth=1, style=plot.style_circles)

plotshape(is_valid_mother and is_daughter, title="Inside Candle", location=location.belowbar, style=shape.diamond, color=color.purple, size=size.tiny)

//==================== ALERTS ====================
alertcondition(buy_condition, title="Buy Signal", message="Inside Candle Buy Breakout")
alertcondition(sell_condition, title="Sell Signal", message="Inside Candle Sell Breakout")

//==================== TABLE ====================
var table t = table.new(position.top_right, 2, 7)

if barstate.islast
    table.cell(t,0,0,"Mother Valid")
    table.cell(t,1,0,str.tostring(is_valid_mother))

    table.cell(t,0,1,"Valid Daughter")
    table.cell(t,1,1,str.tostring(is_daughter))

    table.cell(t,0,2,"Setup Active")
    table.cell(t,1,2,str.tostring(setup_active))

    table.cell(t,0,3,"Mother High")
    table.cell(t,1,3,str.tostring(mother_high))

    table.cell(t,0,4,"Mother Low")
    table.cell(t,1,4,str.tostring(mother_low))

    table.cell(t,0,5,"Breakout Done")
    table.cell(t,1,5,str.tostring(breakout_done))

    table.cell(t,0,6,"Daughter Ratio")
    table.cell(t,1,6,str.tostring(math.round(daughter_body_ratio * 100)) + "%")
````
