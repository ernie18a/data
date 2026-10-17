# ATR Stop Loss Calculator v2 Trade4Green

- url: https://www.tradingview.com/script/vFO0ksP3-ATR-Stop-Loss-Calculator-v2-Trade4Green/
- type: indicator
- pine_id: PUB;ab958a8ff6314a85878fe83e1a0c580d
- version: 1.0

## Description

ATR Stop Loss Calculator

The ATR Stop Loss Calculator is a risk management tool that helps traders determine precise stop loss levels based on the Average True Range (ATR), a widely used volatility indicator developed by J. Welles Wilder. Rather than placing stop losses at arbitrary levels, this indicator anchors them to actual market volatility, ensuring your stop is proportional to how much the market is currently moving.

How it works

The indicator calculates the ATR over a configurable lookback period (default 14 candles) for each of the last 5 closed candles. Each candle is assigned an ID, where ID 1 represents the most recently closed candle and ID 5 the candle closed five bars ago. The ATR value of each candle is multiplied by a configurable multiplier (default 2.5) to produce the stop loss distance. This multiplier controls how much breathing room you give the trade relative to current volatility.

Stop loss calculation

Once you enter your entry price and select Buy or Sell, the indicator automatically calculates your stop loss price:

Buy trade: Entry price minus (ATR × multiplier)
Sell trade: Entry price plus (ATR × multiplier)
You select which candle ID to base your stop loss on, allowing you to reference the volatility at the exact candle where your setup occurred. An optional extra candle ID input lets you monitor any candle further back, such as candle 25, for additional reference.

How to use it

Add the indicator to your chart
Set your preferred ATR period and multiplier in the settings
Enter your intended entry price and select Buy or Sell
Choose which candle ID corresponds to your trade setup
Read your stop loss price directly from the table in the top right corner
All colors in the table are fully customizable to match your chart style.

## Source Code

````pine
//@version=6
indicator("ATR Stop Loss Calculator", overlay=true)

// Inputs
atr_length  = input.int(14,       title="ATR Periode",                    minval=1)
atr_mult    = input.float(2.5,    title="ATR Multiplier",                 minval=0.1, step=0.1)
entry_price = input.float(0.0,    title="Entry Prijs",                    minval=0)
direction   = input.string("Buy", title="Richting",                       options=["Buy", "Sell"])
candle_id   = input.int(1,        title="Candle ID voor Stop Loss",       minval=1)
custom_id   = input.int(0,        title="Extra Candle ID (0 = uit)",      minval=0)

// Kleuren
col_atr       = input.color(color.yellow,                title="ATR waarde kleur",       group="Kleuren")
col_mult      = input.color(color.orange,                title="ATR × multiplier kleur", group="Kleuren")
col_sl        = input.color(color.red,                   title="Stop Loss kleur",        group="Kleuren")
col_custom_bg = input.color(color.new(color.purple, 50), title="Extra candle ID kleur",  group="Kleuren")
col_buy       = input.color(color.green,                 title="Buy kleur",              group="Kleuren")
col_sell      = input.color(color.red,                   title="Sell kleur",             group="Kleuren")

atr = ta.atr(atr_length)

var table t = table.new(position.top_right, 4, 8,
  bgcolor      = color.new(color.black, 20),
  border_width = 1,
  border_color = color.new(color.gray, 50))

if barstate.islast
    // Header
    table.cell(t, 0, 0, "Candle ID", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 0, "ATR",       text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))
    table.cell(t, 2, 0, "x " + str.tostring(atr_mult), text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))
    table.cell(t, 3, 0, "Stop Loss", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))

    // Rijen 1-5
    for i = 1 to 5
        atr_val  = atr[i]
        sl_dist  = atr_val * atr_mult
        selected = i == candle_id
        row_bg   = selected ? color.new(color.blue, 50) : color.new(color.black, 40)
        sl_txt   = entry_price > 0 and selected ? str.tostring(math.round(direction == "Buy" ? entry_price - sl_dist : entry_price + sl_dist, 2)) : "-"

        table.cell(t, 0, i, "ID " + str.tostring(i),               bgcolor=row_bg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, i, str.tostring(math.round(atr_val, 2)),  bgcolor=row_bg, text_color=col_atr,     text_size=size.small)
        table.cell(t, 2, i, str.tostring(math.round(sl_dist, 2)),  bgcolor=row_bg, text_color=col_mult,    text_size=size.small)
        table.cell(t, 3, i, sl_txt,                                bgcolor=row_bg, text_color=col_sl,      text_size=size.small)

    // Extra candle ID rij
    if custom_id > 0
        c_atr    = atr[custom_id]
        c_dist   = c_atr * atr_mult
        c_sel    = custom_id == candle_id
        c_bg     = c_sel ? color.new(color.blue, 50) : col_custom_bg
        c_sl_txt = entry_price > 0 and c_sel ? str.tostring(math.round(direction == "Buy" ? entry_price - c_dist : entry_price + c_dist, 2)) : "-"

        table.cell(t, 0, 6, "ID " + str.tostring(custom_id),      bgcolor=c_bg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, 6, str.tostring(math.round(c_atr, 2)),   bgcolor=c_bg, text_color=col_atr,     text_size=size.small)
        table.cell(t, 2, 6, str.tostring(math.round(c_dist, 2)),  bgcolor=c_bg, text_color=col_mult,    text_size=size.small)
        table.cell(t, 3, 6, c_sl_txt,                             bgcolor=c_bg, text_color=col_sl,      text_size=size.small)
    else
        table.cell(t, 0, 6, "Extra ID: uit", bgcolor=color.new(color.black, 40), text_color=color.new(color.gray, 40), text_size=size.small)
        table.cell(t, 1, 6, "-",             bgcolor=color.new(color.black, 40), text_color=color.new(color.gray, 40), text_size=size.small)
        table.cell(t, 2, 6, "-",             bgcolor=color.new(color.black, 40), text_color=color.new(color.gray, 40), text_size=size.small)
        table.cell(t, 3, 6, "-",             bgcolor=color.new(color.black, 40), text_color=color.new(color.gray, 40), text_size=size.small)

    // Samenvatting
    sel_atr  = atr[candle_id]
    sel_dist = sel_atr * atr_mult
    final_sl = direction == "Buy" ? entry_price - sel_dist : entry_price + sel_dist
    dir_col  = direction == "Buy" ? col_buy : col_sell

    table.cell(t, 0, 7, "Entry: " + (entry_price > 0 ? str.tostring(entry_price) : "-"), bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7, direction,                                                         bgcolor=color.new(color.gray, 30), text_color=dir_col,    text_size=size.small)
    table.cell(t, 2, 7, "SL:",                                                             bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=size.small)
    table.cell(t, 3, 7, entry_price > 0 ? str.tostring(math.round(final_sl, 2)) : "-",   bgcolor=color.new(color.gray, 30), text_color=col_sl,      text_size=size.normal)
````
