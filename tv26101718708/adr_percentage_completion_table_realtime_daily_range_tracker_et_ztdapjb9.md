# ADR percentage Completion Table Real-Time Daily Range Tracker ET

- url: https://www.tradingview.com/script/ZTdAPJB9-ADR-percentage-Completion-Table-Real-Time-Daily-Range-Tracker-ET/
- type: indicator
- pine_id: PUB;6bcc17d632e1422ba923dcede3951de4
- version: 1.0

## Description

📊 ADR % Completion Table

Track how much of the Average Daily Range (ADR) has been consumed in real time — works correctly on every timeframe from 1 minute to weekly.

─────────────────────────────────
🔍 WHAT IT DOES
─────────────────────────────────
This indicator calculates the 14-day Average Daily Range and compares it to the current day's high-to-low range, showing you exactly what percentage of the ADR has been reached so far today.

The daily session resets at 00:00 UTC-4 (New York midnight), making it ideal for forex, indices, and US equity traders.

─────────────────────────────────
📋 TABLE DISPLAY
─────────────────────────────────
- ADR (14d) — the average daily range over the last 14 completed days
- Day High / Day Low — intraday extremes since session open (00:00 UTC-4)
- Today Range — current high-to-low range in price points
- ADR % — percentage of ADR consumed (color-coded)
- Remaining — how many points are left to complete the ADR

─────────────────────────────────
🎨 COLOR CODING
─────────────────────────────────
🔘 Grey     →   0–49%   (early in the day)
🔵 Blue     →  50–74%   (halfway through)
🟠 Orange   →  75–99%   (nearing completion)
🟢 Green    → 100%+     (ADR fully reached)

─────────────────────────────────
⚙️ SETTINGS
─────────────────────────────────
- ADR Lookback — customize the number of days (default: 14)
- Table Position — 8 placement options
- Text Size — Tiny to Huge
- Show/hide Day High & Low lines on the chart

─────────────────────────────────
✅ KEY FEATURES
─────────────────────────────────
✔ Timeframe-independent — ADR value is identical on 1m, 15m, 1h, 4h, and daily charts
✔ Session-accurate — day range always starts at 00:00 UTC-4 regardless of chart timezone
✔ Clean overlay table — no clutter, just the numbers that matter
✔ Works on all instruments — forex pairs, indices, stocks, futures, crypto

─────────────────────────────────
💡 HOW TO USE IT
─────────────────────────────────
When ADR % is low (grey/blue) early in the session, the market still has room to move. When it reaches orange or green, price has covered most or all of its expected daily range — useful for managing targets, avoiding late entries, and timing exits.

Best used alongside your existing strategy as a context filter, not a standalone signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bachetodolniq

//@version=6
indicator("ADR % Completion Table", overlay=true, max_bars_back=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
adr_length = input.int(14, "ADR Lookback (days)", minval=1)
session_tz = "UTC-4"

tbl_pos = input.string("Bottom Right", "Table Position",
             options=["Top Right","Top Left","Top Center",
                      "Bottom Right","Bottom Left","Bottom Center",
                      "Middle Right","Middle Left"])
txt_size = input.string("Normal", "Text Size",
             options=["Tiny","Small","Normal","Large","Huge"])

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.bottom_right

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

// ─── ADR — always computed on the daily timeframe, chart-TF independent ────────
// We pull the *completed* daily high and low via a daily security call.
// calc_bars_count is set high so history is available on all chart timeframes.
// The SMA of the daily range is also computed inside the daily context so
// the result is always exactly N completed daily candles regardless of chart TF.

f_daily_adr(len) =>
    // daily high/low of the PREVIOUS completed day (index 1 inside daily context)
    d_high  = request.security(syminfo.tickerid, "D", high[1],
                               lookahead=barmerge.lookahead_on,
                               gaps=barmerge.gaps_off)
    d_low   = request.security(syminfo.tickerid, "D", low[1],
                               lookahead=barmerge.lookahead_on,
                               gaps=barmerge.gaps_off)
    d_range = d_high - d_low
    // SMA of the range is also evaluated at the daily series, then returned
    // to the current bar — this is the key: sma runs on daily-resolution data
    request.security(syminfo.tickerid, "D", ta.sma(d_range, len),
                     lookahead=barmerge.lookahead_on,
                     gaps=barmerge.gaps_off)

adr_value = f_daily_adr(adr_length)

// ─── SESSION DETECTION (resets at 00:00 UTC-4) ────────────────────────────────
is_new_day = ta.change(time("D", "0000-0000:1234567", session_tz)) != 0

// ─── CURRENT DAY RANGE (UTC-4 session) ────────────────────────────────────────
var float day_high = na
var float day_low  = na

if is_new_day or na(day_high)
    day_high := high
    day_low  := low
else
    day_high := math.max(day_high, high)
    day_low  := math.min(day_low,  low)

current_range = day_high - day_low
adr_pct       = adr_value > 0 ? (current_range / adr_value) * 100 : 0

// ─── COLOUR LOGIC ─────────────────────────────────────────────────────────────
f_color(pct) =>
    if pct >= 100
        color.new(color.green, 15)
    else if pct >= 75
        color.new(color.orange, 15)
    else if pct >= 50
        color.new(color.blue, 20)
    else
        color.new(color.gray, 20)

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table tbl = na

if barstate.islast
    tbl := table.new(f_pos(tbl_pos), columns=2, rows=7,
                     border_width=1, border_color=color.new(color.gray, 60),
                     bgcolor=color.new(color.black, 70))

    // ── Header ──────────────────────────────────────────────────────────────
    table.cell(tbl, 0, 0, "ADR % TABLE",
               text_color=color.white, text_size=f_size(txt_size),
               text_halign=text.align_center,
               bgcolor=color.new(color.navy, 20))
    table.cell(tbl, 1, 0, syminfo.ticker,
               text_color=color.yellow, text_size=f_size(txt_size),
               text_halign=text.align_center,
               bgcolor=color.new(color.navy, 20))

    // ── Row 1: ADR Value ─────────────────────────────────────────────────────
    table.cell(tbl, 0, 1, "ADR (" + str.tostring(adr_length) + "d)",
               text_color=color.silver, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=color.new(color.black, 70))
    table.cell(tbl, 1, 1, str.tostring(adr_value, format.mintick),
               text_color=color.white, text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=color.new(color.black, 70))

    // ── Row 2: Today High ────────────────────────────────────────────────────
    table.cell(tbl, 0, 2, "Day High",
               text_color=color.silver, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=color.new(color.black, 70))
    table.cell(tbl, 1, 2, str.tostring(day_high, format.mintick),
               text_color=color.lime, text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=color.new(color.black, 70))

    // ── Row 3: Today Low ─────────────────────────────────────────────────────
    table.cell(tbl, 0, 3, "Day Low",
               text_color=color.silver, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=color.new(color.black, 70))
    table.cell(tbl, 1, 3, str.tostring(day_low, format.mintick),
               text_color=color.red, text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=color.new(color.black, 70))

    // ── Row 4: Current Range ─────────────────────────────────────────────────
    table.cell(tbl, 0, 4, "Today Range",
               text_color=color.silver, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=color.new(color.black, 70))
    table.cell(tbl, 1, 4, str.tostring(current_range, format.mintick),
               text_color=color.white, text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=color.new(color.black, 70))

    // ── Row 5: ADR % Completion ───────────────────────────────────────────────
    pct_color = f_color(adr_pct)
    table.cell(tbl, 0, 5, "ADR %",
               text_color=color.white, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=pct_color)
    table.cell(tbl, 1, 5, str.tostring(adr_pct, "#.##") + " %",
               text_color=color.white, text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=pct_color)

    // ── Row 6: Remaining ─────────────────────────────────────────────────────
    remaining = math.max(adr_value - current_range, 0)
    rem_color = adr_pct >= 100 ? color.new(color.green, 30) : color.new(color.black, 70)
    table.cell(tbl, 0, 6, "Remaining",
               text_color=color.silver, text_size=f_size(txt_size),
               text_halign=text.align_left,
               bgcolor=rem_color)
    table.cell(tbl, 1, 6, adr_pct >= 100 ? "DONE" : str.tostring(remaining, format.mintick),
               text_color=adr_pct >= 100 ? color.lime : color.white,
               text_size=f_size(txt_size),
               text_halign=text.align_right,
               bgcolor=rem_color)

// ─── OPTIONAL: Day High/Low lines ─────────────────────────────────────────────
show_lines = input.bool(true, "Show Day High/Low lines")
plot(show_lines ? day_high : na, "Day High", color=color.new(color.lime, 40), linewidth=1, style=plot.style_linebr)
plot(show_lines ? day_low  : na, "Day Low",  color=color.new(color.red,  40), linewidth=1, style=plot.style_linebr)
````
