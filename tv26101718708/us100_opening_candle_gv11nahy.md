# US100 Opening Candle

- url: https://www.tradingview.com/script/Gv11NAhy-US100-Opening-Candle/
- type: indicator
- pine_id: PUB;4f4e4c946149485fb648142499623ab6
- version: 1.0

## Description

**NASDAQ 8AM Opening Candle Strategy**

*Developed by the M71 Community, Costa Rica*

This indicator identifies high-probability trade setups on the NASDAQ (NAS100) based on the 8AM New York session opening candle. The strategy is built on the premise that the first hour of the U.S. pre-market session often establishes directional bias for the following price action.

**Strategy Logic**

At the close of the 8AM candle, the indicator reads its direction:
- If the candle closed **bullish** (close > open) → a **Long** setup is triggered
- If the candle closed **bearish** (close < open) → a **Short** setup is triggered

Entry is taken at the **close of the 8AM candle**, with the Stop Loss placed a few points beyond the candle's wick (low for longs, high for shorts), and the Take Profit targeting a **1:1 risk-reward ratio**.

**Risk Management**
- Stop Loss: X points beyond the high/low of the entry candle
- Take Profit: Equal distance to the Stop Loss (1:1 RR)
- Visual zones are displayed on the chart for both SL and TP areas

**How to Use**
1. Apply to NASDAQ 1H chart
2. Set your timezone and toggle DST if applicable
3. Wait for the 8AM candle to close and follow the signal direction
4. Manage the trade within the displayed SL/TP zones

## Source Code

````pine
//@version=6
indicator(
     title      = "NASDAQ 8AM Opening Candle | M71 Community, Costa Rica",
     shorttitle = "US100-1H",
     overlay    = true
     )

sl_pips     = input.int(5,          "Stop Loss (pips)",     minval=1)
box_velas   = input.int(10,         "Zone Width (candles)", minval=1)
timezone    = input.string("UTC-6",  "Timezone",            options=["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5","UTC-4","UTC-3","UTC-2","UTC-1","UTC","UTC+1","UTC+2","UTC+3","UTC+4","UTC+5","UTC+6","UTC+7","UTC+8","UTC+9","UTC+10","UTC+11","UTC+12"])
dst         = input.bool(false,     "Daylight Saving Time (DST)")
target_hour = input.int(7,          "Entry Hour (base)",    minval=0, maxval=23)

col_sl = input.color(color.new(color.red,   70), "SL Zone Color")
col_tp = input.color(color.new(color.green, 70), "TP Zone Color")

actual_hour = dst ? target_hour + 1 : target_hour

bar_hour   = hour(time, timezone)
bar_minute = minute(time, timezone)

is_target_bar = (bar_hour == actual_hour) and (bar_minute == 0) and timeframe.isintraday
is_bullish    = close >= open
is_bearish    = close <  open

signal_bull = is_target_bar and is_bullish
signal_bear = is_target_bar and is_bearish

var float v_entry     = na
var float v_sl        = na
var float v_tp        = na
var int   v_bar_start = na

if signal_bull
    v_entry     := close
    v_sl        := low - sl_pips
    v_tp        := v_entry + (v_entry - v_sl)
    v_bar_start := bar_index

if signal_bear
    v_entry     := close
    v_sl        := high + sl_pips
    v_tp        := v_entry - (v_sl - v_entry)
    v_bar_start := bar_index

in_zone    = not na(v_bar_start) and (bar_index >= v_bar_start) and (bar_index <= v_bar_start + box_velas)
plot_tp    = in_zone ? v_tp    : na
plot_entry = in_zone ? v_entry : na
plot_sl    = in_zone ? v_sl    : na

p_tp    = plot(plot_tp,    "TP",    color=color.green, linewidth=2, style=plot.style_linebr)
p_entry = plot(plot_entry, "Entry", color=color.blue,  linewidth=2, style=plot.style_linebr)
p_sl    = plot(plot_sl,    "SL",    color=color.red,   linewidth=2, style=plot.style_linebr)

fill(p_tp,    p_entry, color=col_tp)
fill(p_entry, p_sl,    color=col_sl)

plotshape(signal_bull, title="Long",  style=shape.triangleup,
         location=location.belowbar, color=color.lime, size=size.small)
plotshape(signal_bear, title="Short", style=shape.triangledown,
         location=location.abovebar, color=color.red,  size=size.small)
````
