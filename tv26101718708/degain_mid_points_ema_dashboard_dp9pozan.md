# Degain Mid Points + EMA Dashboard 

- url: https://www.tradingview.com/script/dp9poZAn-Degain-Mid-Points-EMA-Dashboard/
- type: indicator
- pine_id: PUB;938228795719442a93f9c5f69ea5d6da
- version: 1.0

## Description

igh_3D = request.security(syminfo.tickerid, "D", ta.highest(high, 3), barmerge.gaps_off, barmerge.lookahead_off)
low_3D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 3), barmerge.gaps_off, barmerge.lookahead_off)
mid_3D  = (high_3D + low_3D) / 2

high_7D = request.security(syminfo.tickerid, "D", ta.highest(high, 7), barmerge.gaps_off, barmerge.lookahead_off)
low_7D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 7), barmerge.gaps_off, barmerge.lookahead_off)
mid_7D  = (high_7D + low_7D) / 2

high_20D = request.security(syminfo.tickerid, "D", ta.highest(high, 20), barmerge.gaps_off, barmerge.lookahead_off)
low_20D  = request.security(symi

## Source Code

````pine
//@version=6
indicator("Degain Mid Points + EMA Dashboard ", overlay=true)

// =======================
// DAILY DATA
// =======================
dHigh  = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_off)
dLow   = request.security(syminfo.tickerid, "D", low, barmerge.gaps_off, barmerge.lookahead_off)
dClose = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)

// =======================
// MIDPOINTS
// =======================
mid_1D = (dHigh + dLow) / 2

high_3D = request.security(syminfo.tickerid, "D", ta.highest(high, 3), barmerge.gaps_off, barmerge.lookahead_off)
low_3D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 3), barmerge.gaps_off, barmerge.lookahead_off)
mid_3D  = (high_3D + low_3D) / 2

high_7D = request.security(syminfo.tickerid, "D", ta.highest(high, 7), barmerge.gaps_off, barmerge.lookahead_off)
low_7D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 7), barmerge.gaps_off, barmerge.lookahead_off)
mid_7D  = (high_7D + low_7D) / 2

high_20D = request.security(syminfo.tickerid, "D", ta.highest(high, 20), barmerge.gaps_off, barmerge.lookahead_off)
low_20D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 20), barmerge.gaps_off, barmerge.lookahead_off)
mid_20D  = (high_20D + low_20D) / 2

high_50D = request.security(syminfo.tickerid, "D", ta.highest(high, 50), barmerge.gaps_off, barmerge.lookahead_off)
low_50D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 50), barmerge.gaps_off, barmerge.lookahead_off)
mid_50D  = (high_50D + low_50D) / 2

high_100D = request.security(syminfo.tickerid, "D", ta.highest(high, 100), barmerge.gaps_off, barmerge.lookahead_off)
low_100D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 100), barmerge.gaps_off, barmerge.lookahead_off)
mid_100D  = (high_100D + low_100D) / 2

// ➕ 200D
high_200D = request.security(syminfo.tickerid, "D", ta.highest(high, 200), barmerge.gaps_off, barmerge.lookahead_off)
low_200D  = request.security(syminfo.tickerid, "D", ta.lowest(low, 200), barmerge.gaps_off, barmerge.lookahead_off)
mid_200D  = (high_200D + low_200D) / 2

// =======================
// EMA
// =======================
ema_1   = close
ema_3   = request.security(syminfo.tickerid, "D", ta.ema(close, 3), barmerge.gaps_off, barmerge.lookahead_off)
ema_8   = request.security(syminfo.tickerid, "D", ta.ema(close, 8), barmerge.gaps_off, barmerge.lookahead_off)
ema_20  = request.security(syminfo.tickerid, "D", ta.ema(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
ema_50  = request.security(syminfo.tickerid, "D", ta.ema(close, 50), barmerge.gaps_off, barmerge.lookahead_off)
ema_100 = request.security(syminfo.tickerid, "D", ta.ema(close, 100), barmerge.gaps_off, barmerge.lookahead_off)
ema_200 = request.security(syminfo.tickerid, "D", ta.ema(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

// =======================
// MA 9
// =======================
ma_9 = request.security(syminfo.tickerid, "D", ta.sma(close, 9), barmerge.gaps_off, barmerge.lookahead_off)

// =======================
// TABLE
// =======================
var table t = table.new(position.top_right, 5, 10)

if barstate.islast
    table.cell(t, 0, 0, "Period", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "High/Low", bgcolor=color.black, text_color=color.white)
    table.cell(t, 2, 0, "Midpoint", bgcolor=color.black, text_color=color.white)
    table.cell(t, 3, 0, "EMA", bgcolor=color.black, text_color=color.white)
    table.cell(t, 4, 0, "Value", bgcolor=color.black, text_color=color.white)

    // 1D (EMA 1)
    table.cell(t, 0, 1, "1D")
    table.cell(t, 1, 1, str.tostring(dHigh, "#") + "/" + str.tostring(dLow, "#"))
    table.cell(t, 2, 1, str.tostring(mid_1D, "#"))
    table.cell(t, 3, 1, "1")
    table.cell(t, 4, 1, str.tostring(ema_1, "#"))

    // 3D (EMA 3)
    table.cell(t, 0, 2, "3D")
    table.cell(t, 1, 2, str.tostring(high_3D, "#") + "/" + str.tostring(low_3D, "#"))
    table.cell(t, 2, 2, str.tostring(mid_3D, "#"))
    table.cell(t, 3, 2, "3")
    table.cell(t, 4, 2, str.tostring(ema_3, "#"))

    // 7D (EMA 8)
    table.cell(t, 0, 3, "7D")
    table.cell(t, 1, 3, str.tostring(high_7D, "#") + "/" + str.tostring(low_7D, "#"))
    table.cell(t, 2, 3, str.tostring(mid_7D, "#"))
    table.cell(t, 3, 3, "8")
    table.cell(t, 4, 3, str.tostring(ema_8, "#"))

    // 20D (EMA 20)
    table.cell(t, 0, 4, "20D")
    table.cell(t, 1, 4, str.tostring(high_20D, "#") + "/" + str.tostring(low_20D, "#"))
    table.cell(t, 2, 4, str.tostring(mid_20D, "#"))
    table.cell(t, 3, 4, "20")
    table.cell(t, 4, 4, str.tostring(ema_20, "#"))

    // 50D (EMA 50)
    table.cell(t, 0, 5, "50D")
    table.cell(t, 1, 5, str.tostring(high_50D, "#") + "/" + str.tostring(low_50D, "#"))
    table.cell(t, 2, 5, str.tostring(mid_50D, "#"))
    table.cell(t, 3, 5, "50")
    table.cell(t, 4, 5, str.tostring(ema_50, "#"))

    // 100D (EMA 100)
    table.cell(t, 0, 6, "100D")
    table.cell(t, 1, 6, str.tostring(high_100D, "#") + "/" + str.tostring(low_100D, "#"))
    table.cell(t, 2, 6, str.tostring(mid_100D, "#"))
    table.cell(t, 3, 6, "100")
    table.cell(t, 4, 6, str.tostring(ema_100, "#"))

    // ➕ 200D (EMA 200)
    table.cell(t, 0, 7, "200D")
    table.cell(t, 1, 7, str.tostring(high_200D, "#") + "/" + str.tostring(low_200D, "#"))
    table.cell(t, 2, 7, str.tostring(mid_200D, "#"))
    table.cell(t, 3, 7, "200")
    table.cell(t, 4, 7, str.tostring(ema_200, "#"))

    // MA9
    table.cell(t, 0, 8, "MA 9")
    table.cell(t, 3, 8, "9")
    table.cell(t, 4, 8, str.tostring(ma_9, "#"))
````
