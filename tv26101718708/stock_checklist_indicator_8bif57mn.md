# Stock Checklist Indicator

- url: https://www.tradingview.com/script/8biF57mN-Stock-Checklist-Indicator/
- type: indicator
- pine_id: PUB;840f17b31ef54625b3991f2880490ef9
- version: 1.0

## Description

How to Find and trade momentum stocks. Simple trading strategy for free).Works with all asset classes. This indicator was made following Camel Finance video, https://www.youtube.com/watch?v=Tl1ObCPO9m0.

## Source Code

````pine
//@version=5
indicator("Stock Checklist Indicator", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
ma_type           = input.string("SMA", "MA Type", options=["SMA","EMA"], group="Moving Averages")
show_label        = input.bool(true,  "Show Buy Signal Label",  group="Display")
show_table        = input.bool(true,  "Show Checklist Table",   group="Display")
color_candles     = input.bool(true,  "Color Candles",          group="Display")
pct_from_52w_low  = input.float(30.0, "Max % above 52-week low",  minval=1, group="52-Week Range")
pct_from_52w_high = input.float(25.0, "Max % below 52-week high", minval=1, group="52-Week Range")

// ─── MOVING AVERAGES ──────────────────────────────────────────────────────────
ma(src, len) => ma_type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

ma50  = ma(close, 50)
ma150 = ma(close, 150)
ma200 = ma(close, 200)

plot(ma50,  "50 MA",  color=color.new(color.blue,   0), linewidth=1)
plot(ma150, "150 MA", color=color.new(color.orange, 0), linewidth=1)
plot(ma200, "200 MA", color=color.new(color.red,    0), linewidth=2)

// ─── SUPER GUPPY (GMMA) ───────────────────────────────────────────────────────
s1 = ta.ema(close, 3)
s2 = ta.ema(close, 5)
s3 = ta.ema(close, 8)
s4 = ta.ema(close, 10)
s5 = ta.ema(close, 12)
s6 = ta.ema(close, 15)
l1 = ta.ema(close, 30)
l2 = ta.ema(close, 35)
l3 = ta.ema(close, 40)
l4 = ta.ema(close, 45)
l5 = ta.ema(close, 50)
l6 = ta.ema(close, 60)

short_bullish    = s1 > s2 and s2 > s3 and s3 > s4 and s4 > s5 and s5 > s6
long_bullish     = l1 > l2 and l2 > l3 and l3 > l4 and l4 > l5 and l5 > l6
short_above_long = s6 > l1
guppy_green      = short_bullish and long_bullish and short_above_long

guppy_col_short = guppy_green ? color.new(color.lime,  60) : color.new(color.red,    60)
guppy_col_long  = guppy_green ? color.new(color.teal,  60) : color.new(color.maroon, 60)

plot(s1, "G-S1", color=guppy_col_short, linewidth=1)
plot(s2, "G-S2", color=guppy_col_short, linewidth=1)
plot(s3, "G-S3", color=guppy_col_short, linewidth=1)
plot(s4, "G-S4", color=guppy_col_short, linewidth=1)
plot(s5, "G-S5", color=guppy_col_short, linewidth=1)
plot(s6, "G-S6", color=guppy_col_short, linewidth=1)
plot(l1, "G-L1", color=guppy_col_long,  linewidth=1)
plot(l2, "G-L2", color=guppy_col_long,  linewidth=1)
plot(l3, "G-L3", color=guppy_col_long,  linewidth=1)
plot(l4, "G-L4", color=guppy_col_long,  linewidth=1)
plot(l5, "G-L5", color=guppy_col_long,  linewidth=1)
plot(l6, "G-L6", color=guppy_col_long,  linewidth=1)

// ─── CRITERIA ─────────────────────────────────────────────────────────────────
crit_above_50    = close > ma50
crit_above_150   = close > ma150
crit_above_200   = close > ma200
crit_stacked     = ma50 > ma150 and ma150 > ma200
crit_200_uptrend = ma200 > ma200[21]

low52  = ta.lowest(low,   252)
high52 = ta.highest(high, 252)
crit_near_52w_low  = close <= low52  * (1 + pct_from_52w_low  / 100)
crit_near_52w_high = close >= high52 * (1 - pct_from_52w_high / 100)
crit_breakout      = high > ta.highest(high, 20)[1]
crit_guppy         = guppy_green

all_met = crit_above_50 and crit_above_150 and crit_above_200
       and crit_stacked and crit_200_uptrend
       and crit_near_52w_low and crit_near_52w_high
       and crit_breakout and crit_guppy

// ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────────
tc(ok) => ok ? color.lime : color.red
mk(ok) => ok ? "✔" : "✘"

// ─── CANDLE COLORING ──────────────────────────────────────────────────────────
barcolor(color_candles and all_met ? color.new(color.lime, 0) : na)

// ─── BUY SIGNAL LABEL ─────────────────────────────────────────────────────────
if show_label and all_met
    label.new(bar_index, low, "✔ ALL CLEAR", style=label.style_label_up, color=color.new(color.lime, 10), textcolor=color.black, size=size.normal, yloc=yloc.belowbar)

// ─── DASHBOARD TABLE ──────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.gray, 40))

table.cell(dash, 0, 0, "Criteria", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 10))
table.cell(dash, 1, 0, "Status",   text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 10))

table.cell(dash, 0, 1, "Price > 50 "  + ma_type, text_color=color.white, text_size=size.small)
table.cell(dash, 1, 1, mk(crit_above_50),   text_color=tc(crit_above_50),    text_size=size.small)

table.cell(dash, 0, 2, "Price > 150 " + ma_type, text_color=color.white, text_size=size.small)
table.cell(dash, 1, 2, mk(crit_above_150),  text_color=tc(crit_above_150),   text_size=size.small)

table.cell(dash, 0, 3, "Price > 200 " + ma_type, text_color=color.white, text_size=size.small)
table.cell(dash, 1, 3, mk(crit_above_200),  text_color=tc(crit_above_200),   text_size=size.small)

table.cell(dash, 0, 4, "MAs Stacked (50>150>200)", text_color=color.white, text_size=size.small)
table.cell(dash, 1, 4, mk(crit_stacked),     text_color=tc(crit_stacked),    text_size=size.small)

table.cell(dash, 0, 5, "200 MA Up 1+ Month", text_color=color.white, text_size=size.small)
table.cell(dash, 1, 5, mk(crit_200_uptrend), text_color=tc(crit_200_uptrend),text_size=size.small)

table.cell(dash, 0, 6, "Within " + str.tostring(pct_from_52w_low, "#.#") + "% of 52W Low", text_color=color.white, text_size=size.small)
table.cell(dash, 1, 6, mk(crit_near_52w_low),  text_color=tc(crit_near_52w_low),  text_size=size.small)

table.cell(dash, 0, 7, "Within " + str.tostring(pct_from_52w_high, "#.#") + "% of 52W High", text_color=color.white, text_size=size.small)
table.cell(dash, 1, 7, mk(crit_near_52w_high), text_color=tc(crit_near_52w_high), text_size=size.small)

table.cell(dash, 0, 8, "20-Bar Breakout",   text_color=color.white, text_size=size.small)
table.cell(dash, 1, 8, mk(crit_breakout),   text_color=tc(crit_breakout),   text_size=size.small)

table.cell(dash, 0, 9, "Super Guppy Green", text_color=color.white, text_size=size.small)
table.cell(dash, 1, 9, mk(crit_guppy),      text_color=tc(crit_guppy),      text_size=size.small)
````
