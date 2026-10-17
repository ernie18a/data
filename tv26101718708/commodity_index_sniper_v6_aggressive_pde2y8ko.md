# Commodity & Index Sniper v6 - Aggressive

- url: https://www.tradingview.com/script/PDe2Y8Ko-Commodity-Index-Sniper-v6-Aggressive/
- type: indicator
- pine_id: PUB;bdeb66d6202f4387a1601595d3a7a12d
- version: 3.0

## Description

Indicator shows calculated contract size according to swing point and set USD risk.
Main idea to use with CCT [masterchi] indicator.

## Source Code

````pine
//@version=6
indicator("Commodity & Index Sniper v7.1", overlay=true)

// --- SETTINGS ---
instrument = input.string("MCL (Micro Crude)", "Select Instrument", options=["MNQ", "NQ", "MES", "ES", "MGC (Micro Gold)", "GC (Gold)", "MCL (Micro Crude)", "CL (Crude Oil)"])
risk_usd = input.float(250.0, "Risk per Trade ($)", minval=1.0)
lookback = input.int(2, "Closest Swing (Candles Lookback)", minval=1, tooltip="Smaller number = tighter SL = more contracts.")

// --- NO-TRADE ZONE SETTINGS ---
show_no_trade = input.bool(true, "Show No-Trade Zones (Background)", group="Time Settings")
min_before = input.int(5, "Minutes before top of the hour", minval=0, maxval=30, group="Time Settings")
min_after = input.int(10, "Minutes after top of the hour", minval=0, maxval=30, group="Time Settings")

// --- VISUAL SETTINGS ---
show_shapes = input.bool(true, "Show SL Levels as Lines", group="Visuals")

// --- NO-TRADE LOGIC ---
// Get current minute (0-59)
current_min = minute(time)

// Check if we are in the restricted time zone
is_no_trade = (current_min >= (60 - min_before)) or (current_min <= min_after)

// Color the background
bgcolor(show_no_trade and is_no_trade ? color.new(color.red, 90) : na, title="No-Trade Zone")

// --- POINT VALUES ---
float pt_val = switch instrument
    "MNQ" => 2.0
    "NQ"  => 20.0
    "MES" => 5.0
    "ES"  => 50.0
    "MGC (Micro Gold)"  => 10.0
    "GC (Gold)"         => 100.0
    "MCL (Micro Crude)" => 100.0
    "CL (Crude Oil)"    => 1000.0
    => 2.0

// --- AGGRESSIVE LOGIC (Closest High/Low) ---
instant_sh = ta.highest(high, lookback)
instant_sl = ta.lowest(low, lookback)

// --- CALCULATIONS ---
dist_to_sh = math.max(syminfo.mintick, math.abs(close - instant_sh))
dist_to_sl = math.max(syminfo.mintick, math.abs(close - instant_sl))

qty_short = risk_usd / (dist_to_sh * pt_val)
qty_long  = risk_usd / (dist_to_sl * pt_val)

// --- VISUALIZATION ---
plot(show_shapes ? instant_sh : na, "Short SL Level", color=color.new(color.red, 50), style=plot.style_linebr)
plot(show_shapes ? instant_sl : na, "Long SL Level", color=color.new(color.green, 50), style=plot.style_linebr)

// --- INFO TABLE ---
var table info = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(info, 0, 0, "INSTRUMENT: " + instrument, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, "RISK: $" + str.tostring(risk_usd), text_color=color.yellow, text_size=size.small)
    
    table.cell(info, 0, 1, "LONG (SL: " + str.tostring(instant_sl) + ")", text_color=color.lime, text_halign=text.align_left)
    table.cell(info, 1, 1, str.tostring(qty_long, "#.##"), text_color=color.lime, text_size=size.large) // 'qty' poistettu
    
    table.cell(info, 0, 2, "SHORT (SL: " + str.tostring(instant_sh) + ")", text_color=color.orange, text_halign=text.align_left)
    table.cell(info, 1, 2, str.tostring(qty_short, "#.##"), text_color=color.orange, text_size=size.large) // 'qty' poistettu

    table.cell(info, 0, 3, "SL DISTANCE IN POINTS", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 3, "L:" + str.tostring(dist_to_sl) + " | S:" + str.tostring(dist_to_sh), text_color=color.gray, text_size=size.tiny)
    
    // Status Indicator
    status_color = is_no_trade ? color.red : color.lime
    status_text = is_no_trade ? "NO TRADE ZONE" : "CLEAR TO TRADE"
    table.cell(info, 0, 4, "STATUS", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, status_text, text_color=status_color, text_size=size.small, text_halign=text.align_center)
````
