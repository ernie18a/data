# VWAP TF

- url: https://www.tradingview.com/script/PGq3escN-VWAP-TF/
- type: indicator
- pine_id: PUB;e03808654dfd487c85d2f6fca0f767e7
- version: 1.0

## Description

Gosly
112222222222222
daxxxxxxxx
xaxaaaaaaaaaaaaa
sssssssdddwwwwwwwwwwww
aassssssssss

## Source Code

````pine
//@version=5
indicator("VWAP Daily Bands", shorttitle="VWAP Daily", overlay=true, max_bars_back=500)

// ============================================================
//  INPUTS
// ============================================================

grp1 = "VWAP Settings"
src          = input.source(hl2, "Source", group=grp1)
show_vwap    = input.bool(true, "Show VWAP", group=grp1)

grp2 = "Deviation Bands"
show_b1      = input.bool(true,  "Show Band 1", group=grp2)
show_b2      = input.bool(true,  "Show Band 2", group=grp2)
show_b3      = input.bool(true,  "Show Band 3", group=grp2)
mult1        = input.float(1.0,  "Band 1 Multiplier", step=0.1, group=grp2)
mult2        = input.float(2.0,  "Band 2 Multiplier", step=0.1, group=grp2)
mult3        = input.float(3.0,  "Band 3 Multiplier", step=0.1, group=grp2)

grp3 = "Anchor"
anchor       = input.string("Week", "Anchor Period", options=["Day","Week","Month","Quarter","Year"], group=grp3)

// ============================================================
//  ANCHOR DETECTION
// ============================================================

is_new_anchor = switch anchor
    "Day"     => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Quarter" => month != month[1] and (month == 1 or month == 4 or month == 7 or month == 10)
    "Year"    => timeframe.change("12M")
    => timeframe.change("W")

// ============================================================
//  VWAP CALCULATION — acumulado por periodo anchor
// ============================================================

var float sum_pv  = 0.0
var float sum_v   = 0.0
var float sum_pv2 = 0.0

if is_new_anchor
    sum_pv  := src * volume
    sum_v   := volume
    sum_pv2 := src * src * volume
else
    sum_pv  := nz(sum_pv[1])  + src * volume
    sum_v   := nz(sum_v[1])   + volume
    sum_pv2 := nz(sum_pv2[1]) + src * src * volume

vwap_val = sum_pv / sum_v
variance = math.max(sum_pv2 / sum_v - vwap_val * vwap_val, 0.0)
stdev    = math.sqrt(variance)

upper1 = vwap_val + mult1 * stdev
lower1 = vwap_val - mult1 * stdev
upper2 = vwap_val + mult2 * stdev
lower2 = vwap_val - mult2 * stdev
upper3 = vwap_val + mult3 * stdev
lower3 = vwap_val - mult3 * stdev

// ============================================================
//  COLORS — estilo gris/blanco como la imagen
// ============================================================

col_vwap   = color.new(#000000, 0)
col_b1     = color.new(#9E9E9E, 0)
col_b2     = color.new(#757575, 0)
col_b3     = color.new(#424242, 0)
col_fill1  = color.new(#BDBDBD, 88)
col_fill2  = color.new(#9E9E9E, 88)
col_fill3  = color.new(#757575, 88)

// ============================================================
//  PLOTS
// ============================================================

p_vwap = plot(show_vwap ? vwap_val : na, "VWAP", col_vwap, 2)

p_u1 = plot(show_b1 ? upper1 : na, "Upper Band 1", col_b1, 1)
p_l1 = plot(show_b1 ? lower1 : na, "Lower Band 1", col_b1, 1)
p_u2 = plot(show_b2 ? upper2 : na, "Upper Band 2", col_b2, 1)
p_l2 = plot(show_b2 ? lower2 : na, "Lower Band 2", col_b2, 1)
p_u3 = plot(show_b3 ? upper3 : na, "Upper Band 3", col_b3, 1)
p_l3 = plot(show_b3 ? lower3 : na, "Lower Band 3", col_b3, 1)

// Fills entre bandas
fill(p_u1, p_l1, col_fill1, "Band 1 Fill")
fill(p_u2, p_u1, col_fill2, "Band 2 Upper Fill")
fill(p_l1, p_l2, col_fill2, "Band 2 Lower Fill")
fill(p_u3, p_u2, col_fill3, "Band 3 Upper Fill")
fill(p_l2, p_l3, col_fill3, "Band 3 Lower Fill")
````
