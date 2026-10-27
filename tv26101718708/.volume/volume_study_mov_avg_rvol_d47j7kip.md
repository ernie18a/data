# Volume study Mov Avg & Rvol

- url: https://www.tradingview.com/script/d47J7kiP-Volume-study-Mov-Avg-Rvol/
- type: indicator
- pine_id: PUB;1dc8f00849ab442ca43614b459cbfe54
- version: 1.0

## Description

Hello nerds,

this lower pane indicator shows us the actual volume on the timeframe, the average volume on x past days (configurable).

It also shows the Relative volume of a weekly period compared to  x past weeks (configurable)

and also  the Relative volume of a monthly period compared to  x past months (configurable)

Thresholds of a higher volume will highlight in lighter green if let's say you set an alert at 1.2x the average volume of 6 past weeks.

Go to settings and play around.

I'm pretty happy with the defaults.

Volume is key to spot trend and institutional sponsorship, my friends.

This was written with our friend Claude and of course is open source.

Kind regards from Portugal.

## Source Code

````pine
// This source code is subject to the Mozilla Public License 2.0
// © Martybird92

//@version=6
indicator("Volume study Mov Avg & Rvol", shorttitle="VOL MA RVOL", format=format.volume)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
ma_type     = input.string("SMA", "MA Type",
                options=["SMA", "EMA", "WMA", "HMA", "VWMA"])
ma_len      = input.int(20,  "MA Length",                    minval=1)
rvolW_len   = input.int(10,  "R-Vol Weekly Lookback (weeks)",  minval=1)
rvolM_len   = input.int(6,   "R-Vol Monthly Lookback (months)", minval=1)
rvolW_thr   = input.int(150, "R-Vol Weekly Threshold (%)",    minval=100, step=10,
                tooltip="Au-dessus de ce seuil → vert flashy")
rvolM_thr   = input.int(150, "R-Vol Monthly Threshold (%)",   minval=100, step=10,
                tooltip="Au-dessus de ce seuil → vert flashy")
col_up      = input.color(color.new(color.teal,  60), "Vol Up Color")
col_dn      = input.color(color.new(color.red,   60), "Vol Down Color")
col_ma      = input.color(color.new(color.yellow, 0), "MA Color")
tbl_size    = input.string(size.small, "Table Text Size",
                options=[size.tiny, size.small, size.normal, size.large])

// ─── MA CALCULATION ───────────────────────────────────────────────────────────
vol_ma(src, len, t) =>
    switch t
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "HMA"  => ta.hma(src, len)
        "VWMA" => ta.vwma(src, len)
        =>        ta.sma(src, len)

ma = vol_ma(volume, ma_len, ma_type)

// ─── Weekly R-Vol (semaine passée) ────────────────────────────────────────────
weeklyVol    = request.security(syminfo.tickerid, "W", volume[1],                    lookahead=barmerge.lookahead_on)
weeklyVolAvg = request.security(syminfo.tickerid, "W", ta.sma(volume, rvolW_len)[1], lookahead=barmerge.lookahead_on)
rVolW        = weeklyVolAvg > 0 ? weeklyVol / weeklyVolAvg * 100 : na

// ─── Monthly R-Vol (mois passé) ───────────────────────────────────────────────
monthlyVol    = request.security(syminfo.tickerid, "M", volume[1],                    lookahead=barmerge.lookahead_on)
monthlyVolAvg = request.security(syminfo.tickerid, "M", ta.sma(volume, rvolM_len)[1], lookahead=barmerge.lookahead_on)
rVolM         = monthlyVolAvg > 0 ? monthlyVol / monthlyVolAvg * 100 : na

// ─── FORMAT HELPER ────────────────────────────────────────────────────────────
fmt(v) =>
    if v >= 1e9
        str.tostring(math.round(v / 1e9, 2)) + "B"
    else if v >= 1e6
        str.tostring(math.round(v / 1e6, 2)) + "M"
    else if v >= 1e3
        str.tostring(math.round(v / 1e3, 1)) + "K"
    else
        str.tostring(math.round(v, 0))

// ─── COLOR HELPER ─────────────────────────────────────────────────────────────
rvolColor(val, thr) =>
    if na(val)
        color.new(color.gray, 40)
    else if val >= thr
        color.new(#01b64c, 0)       // vert flashy au-dessus du seuil
    else if val >= 100
        color.new(color.teal, 20)   // vert normal au-dessus de la moyenne
    else
        color.new(color.red, 20)    // rouge en dessous de la moyenne

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(volume, style=plot.style_columns,
     color = close >= open ? col_up : col_dn,
     title = "Volume")

plot(ma, color=col_ma, linewidth=2, title="Vol MA")

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table tbl = table.new(
     position     = position.top_center,
     columns      = 4,
     rows         = 1,
     border_width = 1,
     border_color = color.new(color.gray, 60))

if barstate.islast
    vol_color = close >= open ? col_up : col_dn

    // ── Col 0 : MA Volume ─────────────────────────────────────────────────────
    table.cell(tbl, 0, 0,
         ma_type + str.tostring(ma_len) + ": " + fmt(ma),
         text_color = color.black,
         text_size  = tbl_size,
         bgcolor    = col_ma)

    // ── Col 1 : Volume actuel ─────────────────────────────────────────────────
    table.cell(tbl, 1, 0,
         "Vol: " + fmt(volume),
         text_color = color.white,
         text_size  = tbl_size,
         bgcolor    = vol_color)

        // ── Col 2 : R-Vol Mois ────────────────────────────────────────────────────
    mLabel = na(rVolM) ? "M: n/a" : "M: " + str.tostring(math.round(rVolM)) + "%"
    table.cell(tbl, 2, 0,
         mLabel,
         text_color = color.white,
         text_size  = tbl_size,
         bgcolor    = rvolColor(rVolM, rvolM_thr))

    // ── Col 3 : R-Vol Semaine ─────────────────────────────────────────────────
    wLabel = na(rVolW) ? "W: n/a" : "W: " + str.tostring(math.round(rVolW)) + "%"
    table.cell(tbl, 3, 0,
         wLabel,
         text_color = color.white,
         text_size  = tbl_size,
         bgcolor    = rvolColor(rVolW, rvolW_thr))
````
