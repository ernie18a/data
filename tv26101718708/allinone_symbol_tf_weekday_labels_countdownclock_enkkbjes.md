# All-in-One: Symbol, TF, Weekday Labels, Countdown/Clock

- url: https://www.tradingview.com/script/EnKkBJes-All-in-One-Symbol-TF-Weekday-Labels-Countdown-Clock/
- type: indicator
- pine_id: PUB;1cedb01e84624d008b6ed6239bcad74a
- version: 2.0

## Description

All-in-One: Symbol+TF • Weekday Labels • Countdown/Clock
Version 1.0.0

Chart-furniture dashboard that puts four everyday reference pieces on one indicator: a symbol / timeframe / date table, forex-session weekday labels along the bottom, an on-chart candle countdown, and a right-hand Clock and Countdown Panel showing the London clock, the candle countdown and the current candle's open and close time. Each piece toggles on or off independently.

WHAT IT DRAWS
• Symbol and timeframe table: a bottom-right table showing the ticker, the chart timeframe and the current date (weekday plus day-month). Works on every timeframe from seconds up to weekly.
• Weekday labels: forex-session weekday text along the bottom of the chart, drawn on 5m to 4h charts only. Each label is projected forward onto the next session, so the text shows the upcoming day.
• On-chart candle countdown: a floating label to the right of the last bar counting down to the current bar's close, with per-timeframe control over how far right it sits.
• Clock and Countdown Panel: a middle-right table showing any of three rows: the candle countdown, the live London clock, and the current candle's open and close time. The panel sizes itself to the visible rows and stays vertically centred.

HOW IT WORKS
• The countdown reads the time remaining to the current bar's close and updates live. It shows on daily and below (not on weekly or monthly), and a Visibility timeframe input restricts it further if you want it only on the lower timeframes.
• The Clock and Countdown Panel's live clock reads real time, while the candle-time row reads the bar you are on. In Bar Replay the candle time tracks the scrubbed-to bar while the live clock keeps real time. Each of the three rows toggles independently and there is no master toggle: turn all three off to hide the panel.
• The weekday labels draw on 5m to 4h charts only. Below 5m the fixed forward projection (a bar count) throws them far off-screen, and on seconds charts the offset maths mis-places them, so both are gated out. A marker is drawn at each session's open bar but pushed forward so it renders over the next session, which is why Monday's marker reads "Tue", Tuesday's reads "Wed", and so on. Friday reads "Mon", projecting across the closed weekend so Monday's session still gets a label. The Sunday-evening open is not traded, so it is intentionally not labelled.
• Opacity inputs read as true opacity: 0 is invisible and 100 is solid.

EXTENDED TRADING HOURS WHERE THE SYMBOL OFFERS THE CHOICE
The weekday labels need the overnight session-open bar to exist in the data. On any symbol that offers a Regular / Extended hours choice (for example DE40, and some FX feeds), set the chart's Session to "Extended trading hours" (Chart Settings, Symbol, Session, Extended trading hours). On Regular Hours the session-open bar is trimmed out of the series, so the weekday labels simply do not appear. Only the weekday labels depend on this: the countdown, the live clock, the candle time and the symbol/timeframe table read the current bar or real time and work either way. Symbols that trade one continuous session (for example US500, USTEC, XTIUSD) have no such option and are unaffected.

WHAT IT RUNS ON
It runs on any instrument. Only the weekday-label placement is instrument-dependent, so on untested symbols confirm the day labels land where you want them. Tested on ICMarkets data across forex pairs, DE40, XAUUSD, USTEC, US500, XTIUSD and US30.

HOW TO USE
Add it to any chart. Use the symbol/timeframe table and the live clock as an at-a-glance header, and the countdown to see how long the current bar has left. On a 5m to 4h chart, turn on the weekday labels to mark each upcoming session along the bottom (enable Extended Trading Hours first if the symbol offers the choice). Open the Clock and Countdown Panel's candle-time row when working in Bar Replay to read the open and close of the bar you are scrubbed to.

FEEDBACK
Please let me know if you experience any issues, or have feedback for improvements or additions in the comments below. Thank you, Tom

## Source Code

````pine
//@version=6
// =============================================================================
// ALL-IN-ONE: SYMBOL, TF, WEEKDAY LABELS, COUNTDOWN / CLOCK
// =============================================================================
// Author:       Tom Brown
// Description:  Chart-furniture dashboard: a bottom-right symbol / timeframe / date table,
//               forex-session weekday labels along the bottom, an on-chart candle-countdown
//               label, and a right-hand Clock & Countdown Panel (London clock, candle countdown
//               and candle open/close time).
// Version:      1.0.1
// Tested on:    ICMarkets data: forex pairs, DE40, XAUUSD, USTEC, US500, XTIUSD, US30.
//               Runs on any instrument; only the weekday-label placement is instrument-
//               dependent, so on untested symbols confirm the day labels land as you want.
// Date:         2026-09-22
// =============================================================================

indicator("All-in-One: Symbol, TF, Weekday Labels, Countdown/Clock", overlay = true, max_labels_count = 5)

// --- input group headers ------------------------------------------------------
grp_lbl   = "━━━ ON-CHART COUNTDOWN ━━━"
grp_tbl   = "━━━ CLOCK & COUNTDOWN PANEL ━━━"
grp_symtf = "━━━ SYMBOL & TIMEFRAME TABLE ━━━"
grp_day   = "━━━ WEEKDAY LABELS ━━━"

// --- inputs: on-chart countdown -----------------------------------------------
label_tf_visibility    = input.string("All Timeframes", "Visibility timeframe", options = ["15m and below", "1h and below", "4h and below", "All Timeframes"], group = grp_lbl, tooltip = "Which chart timeframes show the on-chart countdown.")
show_countdown_label   = input.bool(true, "Show countdown", group = grp_lbl, tooltip = "Show the candle countdown on the chart.")
bar_time_dist_offset   = input.int(20, "Candle distance from price (other charts)", group = grp_lbl, tooltip = 'How many candles to the right of the last\ncandle the countdown floats.\n\nUsed on all timeframes except 1m / 5m / 15m.')
offset_1m              = input.int(10, "Candle distance from price (1m chart)", group = grp_lbl, tooltip = 'How many candles to the right of the last\ncandle the countdown floats, on the 1m chart.')
offset_5m              = input.int(10, "Candle distance from price (5m chart)", group = grp_lbl, tooltip = 'How many candles to the right of the last\ncandle the countdown floats, on the 5m chart.')
offset_15m             = input.int(10, "Candle distance from price (15m chart)", group = grp_lbl, tooltip = 'How many candles to the right of the last\ncandle the countdown floats, on the 15m chart.')
label_text_colour      = input.color(color.fuchsia, "Countdown text colour", group = grp_lbl, tooltip = "Text colour of the on-chart countdown.")
label_bg_colour        = input.color(color.white, "Countdown background colour", group = grp_lbl, tooltip = "Background colour of the on-chart countdown.")
label_bg_opacity       = input.int(0, "Countdown background opacity", minval = 0, maxval = 100, group = grp_lbl, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
label_size_countdown   = input.string("Huge", "Countdown text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_lbl, tooltip = "Size of the countdown text.")

// --- inputs: clock & countdown panel ------------------------------------------
show_table_countdown = input.bool(false, "Show countdown", group = grp_tbl, tooltip = "Show the candle countdown in the panel.")
show_table_time      = input.bool(true, "Show live time", group = grp_tbl, tooltip = "Show the London clock in the panel.")
show_table_candle    = input.bool(false, "Show candle time", group = grp_tbl, tooltip = 'Show the current candle\'s open/close time in\nthe panel — useful in bar replay.')
table_text_colour    = input.color(color.rgb(54, 58, 69, 49), "Table text colour", group = grp_tbl, tooltip = "Text colour of the panel.")
table_bg_colour      = input.color(color.white, "Table background colour", group = grp_tbl, tooltip = "Background colour of the panel.")
table_bg_opacity     = input.int(0, "Table background opacity", minval = 0, maxval = 100, group = grp_tbl, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
table_size_time      = input.string("Normal", "Time-of-day text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_tbl, tooltip = "Size of the clock text in the panel.")
table_size_countdown = input.string("Normal", "Countdown text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_tbl, tooltip = "Size of the countdown text in the panel.")
table_size_candle    = input.string("Small", "Candle time text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_tbl, tooltip = "Size of the candle open / close text in the panel.")

// --- inputs: symbol & timeframe table -----------------------------------------
sym_tf_text_colour = input.color(color.rgb(54, 58, 69, 49), "Text colour", inline = "symtf", group = grp_symtf, tooltip = "Colour of the symbol / timeframe / date text.")
sym_tf_text_size   = input.string("Large", "Text size", options = ["Small", "Normal", "Large", "Huge"], inline = "symtf", group = grp_symtf, tooltip = "Size of the symbol / timeframe text.")
show_sym_tf_table  = input.bool(true, "Show symbol & timeframe table", group = grp_symtf, tooltip = 'Bottom-right table showing symbol, timeframe\nand date.')

// --- inputs: weekday labels ---------------------------------------------------
show_day_labels  = input.bool(true, "Show day-of-week labels", group = grp_day, tooltip = 'Weekday text along the bottom at each session\nstart (5m-4h charts).')
day_text_colour  = input.color(color.black, "Day label text colour", inline = "day", group = grp_day, tooltip = "Colour of the weekday labels.")
day_text_opacity = input.int(50, "Day label text opacity", minval = 0, maxval = 100, inline = "day", group = grp_day, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")

// --- helpers ------------------------------------------------------------------
is_special_instrument() =>
    syminfo.ticker == "DE40" or syminfo.ticker == "XAUUSD"

f_to_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

// Clock formatted in London time (HH: MM: SS)
f_format_time(t) =>
    h = hour(t, "Europe/London")
    m = minute(t, "Europe/London")
    s = second(t, "Europe/London")
    str.tostring(h, "00") + ": " + str.tostring(m, "00") + ": " + str.tostring(s, "00")

// --- constants / derived ------------------------------------------------------
day_text_adjusted    = color.new(day_text_colour, 100 - day_text_opacity)
// Weekday labels are aimed at 5m-4h. Below 5m the fixed forward projection (a bar count)
// throws them far off-screen, and on seconds charts the offset maths (minute-based) mis-places
// them - so both are gated out. Range: intraday, not seconds, 5 <= multiplier(min) <= 240.
weekday_label_tf = timeframe.isintraday and not timeframe.isseconds and timeframe.multiplier >= 5 and timeframe.multiplier <= 240
bars_in_24_hours     = 24 * 60 / timeframe.multiplier
bars_in_one_hour     = bars_in_24_hours / 24
daily_and_below      = not (timeframe.isweekly or timeframe.ismonthly)

// Forex "start of day" bar (ICMarkets session open, UK-US shifted, matched in UTC).
// UK-US difference hardcoded at 5h (was a 5/4 input toggle) — see the design notes in RULES.md for why.
ukus_time_difference          = 5
forex_session_start_hour      = (is_special_instrument() and syminfo.prefix == "ICMARKETS") ? 5 : 0
forex_session_start_time_diff = (forex_session_start_hour + ukus_time_difference) % 24
forex_session_start_timestamp = timestamp("UTC", year, month, dayofmonth, forex_session_start_time_diff, 0)
is_start_of_day               = time == forex_session_start_timestamp

// On-chart-label visibility for the current timeframe
is_label_tf_allowed = switch label_tf_visibility
    "15m and below" => timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 15)
    "1h and below"  => timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 60)
    "4h and below"  => timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 240)
    => true

// Per-timeframe label X offset
current_tf_offset = switch timeframe.period
    "1"  => offset_1m
    "5"  => offset_5m
    "15" => offset_15m
    => bar_time_dist_offset

// Resolved sizes + backgrounds
label_countdown_text_size = f_to_size(label_size_countdown)
label_bg_adjusted         = color.new(label_bg_colour, 100 - label_bg_opacity)
table_time_text_size      = f_to_size(table_size_time)
table_countdown_text_size = f_to_size(table_size_countdown)
table_candle_text_size    = f_to_size(table_size_candle)
table_bg_adjusted         = color.new(table_bg_colour, 100 - table_bg_opacity)

// --- block 1: symbol & timeframe table ----------------------------------------
var table sym_tf_tbl = na
table_text_size_value = f_to_size(sym_tf_text_size)

display_timeframe = timeframe.isweekly ? "W" : timeframe.isdaily ? "D" : timeframe.period == "420" ? "7h" : timeframe.period == "240" ? "4h" : timeframe.period == "120" ? "2h" : timeframe.period == "60" ? "1h" : timeframe.period == "30" ? "30m" : timeframe.period == "15" ? "15m" : timeframe.period == "5" ? "5m" : timeframe.period == "3" ? "3m" : timeframe.period == "1" ? "1m" : timeframe.period == "15S" ? "15s" : timeframe.period

if barstate.islast
    if show_sym_tf_table
        if na(sym_tf_tbl)
            sym_tf_tbl := table.new(position.bottom_right, 1, 3, bgcolor = color.new(color.gray, 100))
        day_name = dayofweek == dayofweek.monday ? "Mon" : dayofweek == dayofweek.tuesday ? "Tue" : dayofweek == dayofweek.wednesday ? "Wed" : dayofweek == dayofweek.thursday ? "Thu" : dayofweek == dayofweek.friday ? "Fri" : dayofweek == dayofweek.saturday ? "Sat" : "Sun"
        current_date = day_name + " " + str.tostring(dayofmonth, "00") + "-" + str.tostring(month, "00")
        table.cell(sym_tf_tbl, 0, 0, syminfo.ticker,     bgcolor = color.new(color.white, 100), text_color = sym_tf_text_colour, text_size = table_text_size_value)
        table.cell(sym_tf_tbl, 0, 1, display_timeframe,  bgcolor = color.new(color.white, 100), text_color = sym_tf_text_colour, text_size = table_text_size_value)
        table.cell(sym_tf_tbl, 0, 2, current_date,       bgcolor = color.new(color.white, 100), text_color = sym_tf_text_colour, text_size = size.normal)
    else
        if not na(sym_tf_tbl)
            table.delete(sym_tf_tbl)
            sym_tf_tbl := na

// --- block 2: forex-session weekday labels ------------------------------------
// Each marker is drawn at a session's open bar but pushed forward (base offset =
// 24h + 3h) so it lands over the NEXT session; the text is therefore the upcoming
// day (Monday's marker reads "Tue"). Friday reads "Mon" to skip the weekend.
// Sunday's evening open is not traded, so it is intentionally not labelled —
// Monday's label comes from Friday's marker.
//
// The base offset is then nudged PER-INSTRUMENT so every instrument's label lands
// at a consistent 09:00 (calibrated on the 1h ICMarkets chart). Observed "Tue"
// landings before the nudge: forex 09:00, US500/XTIUSD 10:00, XAUUSD/DE40 15:00 —
// the exchange-timezone drift in timestamp() means each instrument needs its own
// shift. The UK-US difference is hardcoded at 5h (see the design notes in RULES.md), so the labels shift
// slightly during the UK/US DST-changeover weeks rather than being re-aligned by a toggle.
day_label_nudge_hours = switch
    syminfo.ticker == "XAUUSD" or syminfo.ticker == "DE40"   => -6
    syminfo.ticker == "US500"  or syminfo.ticker == "XTIUSD" => -1
    => 0
day_label_offset = bars_in_24_hours + (bars_in_one_hour * 3) + (bars_in_one_hour * day_label_nudge_hours)
plotshape(is_start_of_day and show_day_labels and weekday_label_tf and dayofweek == dayofweek.monday,    text = "Tue", color = color.new(color.black, 100), offset = day_label_offset, style = shape.cross, textcolor = day_text_adjusted, size = size.tiny, location = location.bottom)
plotshape(is_start_of_day and show_day_labels and weekday_label_tf and dayofweek == dayofweek.tuesday,   text = "Wed", color = color.new(color.black, 100), offset = day_label_offset, style = shape.cross, textcolor = day_text_adjusted, size = size.tiny, location = location.bottom)
plotshape(is_start_of_day and show_day_labels and weekday_label_tf and dayofweek == dayofweek.wednesday, text = "Thu", color = color.new(color.black, 100), offset = day_label_offset, style = shape.cross, textcolor = day_text_adjusted, size = size.tiny, location = location.bottom)
plotshape(is_start_of_day and show_day_labels and weekday_label_tf and dayofweek == dayofweek.thursday,  text = "Fri", color = color.new(color.black, 100), offset = day_label_offset, style = shape.cross, textcolor = day_text_adjusted, size = size.tiny, location = location.bottom)
plotshape(is_start_of_day and show_day_labels and weekday_label_tf and dayofweek == dayofweek.friday,    text = "Mon", color = color.new(color.black, 100), offset = day_label_offset, style = shape.cross, textcolor = day_text_adjusted, size = size.tiny, location = location.bottom)

// --- block 3: candle countdown + time-of-day ----------------------------------
var label label_countdown = na
var table time_tbl        = na

string countdown_text  = ""
string table_time_text = ""

want_on_chart  = is_label_tf_allowed
want_countdown = (want_on_chart and show_countdown_label) or show_table_countdown
want_time      = show_table_time

if barstate.islast
    if daily_and_below and want_countdown
        int remaining_seconds_total = int(math.max(0, (time_close - timenow) / 1000.0))
        int rh = math.floor(remaining_seconds_total / 3600)
        int rm = math.floor((remaining_seconds_total % 3600) / 60)
        int rs = math.floor(remaining_seconds_total % 60)
        countdown_text := rh > 0 ? "t- " + str.tostring(rh) + "h " + str.tostring(rm) + "m " + str.tostring(rs) + "s" : rm > 0 ? "t- " + str.tostring(rm) + "m " + str.tostring(rs) + "s" : "t- " + str.tostring(rs) + "s"
    if want_time
        table_time_text := "time - " + f_format_time(timenow)

// on-chart countdown label (rebuilt each last-bar tick; deleted first to avoid leftovers)
if barstate.islast
    label.delete(label_countdown)
    if want_on_chart and show_countdown_label and (countdown_text != "")
        label_x   = bar_index + current_tf_offset
        mid_price = (high + low) / 2.0
        label_countdown := label.new(x = label_x, y = mid_price, text = countdown_text, style = label.style_label_center, color = label_bg_adjusted, textcolor = label_text_colour, size = label_countdown_text_size)

// Clock & Countdown Panel — a table rebuilt each last-bar update, sized to exactly the
// visible rows so it stays vertically centred at position.middle_right and grows/shrinks
// as rows toggle
if barstate.islast
    if not na(time_tbl)
        table.delete(time_tbl)
        time_tbl := na
    // Collect the visible rows, in order, with each row's text size
    array<string> row_txt  = array.new<string>()
    array<string> row_size = array.new<string>()
    if show_table_countdown
        array.push(row_txt, countdown_text)
        array.push(row_size, table_countdown_text_size)
    if show_table_time
        array.push(row_txt, table_time_text)
        array.push(row_size, table_time_text_size)
    if show_table_candle
        array.push(row_txt, "")
        array.push(row_size, table_candle_text_size)
        array.push(row_txt, "candle time:")
        array.push(row_size, table_candle_text_size)
        array.push(row_txt, "open - " + f_format_time(time))
        array.push(row_size, table_candle_text_size)
        array.push(row_txt, "close - " + f_format_time(time_close))
        array.push(row_size, table_candle_text_size)
    int row_count = array.size(row_txt)
    if row_count > 0
        time_tbl := table.new(position.middle_right, 1, row_count, bgcolor = table_bg_adjusted, frame_width = 0, frame_color = color.new(color.black, 100))
        for i = 0 to row_count - 1
            table.cell(time_tbl, 0, i, array.get(row_txt, i), text_color = table_text_colour, text_size = array.get(row_size, i), bgcolor = table_bg_adjusted)
````
