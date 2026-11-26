# Daily ATR [Pogiest]

- url: https://www.tradingview.com/script/Zn40E5Ia-Daily-ATR-Pogiest/
- type: indicator
- pine_id: PUB;5f9ed92ef78b4a0e9cc5ebde6d18173f
- version: 1.0

## Description

[b]General[/b]

This Daily ATR indicator is a real-time Average True Range monitor designed for active intraday traders. The indicator displays a live, updating table directly on your chart that shows the daily ATR value alongside the current session's developing range, allowing you to instantly assess how much of the day's expected move has already been consumed.

The ATR is calculated on the daily timeframe and only updates at the close of each session, mirroring the behavior of a standard ATR indicator on a daily chart. The live range (LIVE TR), however, updates in real time as price makes new session highs and lows — so traders always know exactly where they stand relative to the day's expected range, at any moment during the session.

[i]Key differentiators:[/i]

1. Live session tracking — LIVE TR updates as each new tick makes a new intraday high or low, not just on candle closes.
2. Threshold price levels — automatically calculates the price the market needs to reach from both the session high and session low to complete the ATR (or any percentage of it).
3. Two Live TR modes — choose between Session Range (high minus low from the 18:00 EST open) or True Range (which includes the overnight gap from the previous session's close).
4. Percentage rows — add up to two custom ATR percentage rows (e.g. 50%, 75%) to monitor partial ATR completions.
3. Color-coded status — each row shows OVER (red) or UNDER (green).
4. Warning threshold — the LIVE TR status cell turns yellow when the session range reaches 80% of the daily ATR, giving you an early alert before the full ATR is consumed.
5. Fully customizable — every column can be toggled on or off, and all colors are adjustable to match the chart theme.
6. Alerts: Includes three built-in alert conditions accessible for exceeding Daily ATR and Percentage ATRs.

[b]How the Indicator Table Works[/b]

The table is overlaid directly on your chart and updates in real time. Each row represents a different range reference, and each column provides a different dimension of information about that range.

[i]Rows[/i]

DAILY ATR The smoothed Average True Range of the instrument calculated on the daily timeframe. This value only changes once per day when the previous session closes and a new ATR value is calculated. The Status cell shows OVER (red) if today's live range has exceeded the full ATR, or UNDER (green) if it has not.

Percentage ATR (optional) Up to two configurable percentage rows can be enabled. For example, a 50% ATR row shows what half the daily ATR looks like in ticks, points, and price levels. These rows are useful for identifying partial move targets and assessing whether a common retracement or extension level has been reached. The Status cell shows OVER or UNDER based on whether the current live range has exceeded that percentage threshold.

LIVE TR The current session's developing range, updating in real time as new highs and lows are printed. The Status cell displays the live range as a percentage of the daily ATR. It turns yellow at 80% as an early warning, and red when the full ATR is exceeded (100%+).

[i]Columns[/i]

Range The row label identifying what is being measured — DAILY ATR, a percentage row (e.g. 50% ATR), or LIVE TR. The header also displays the active smoothing method and ATR period (e.g. RMA 5).

Ticks (toggleable) The ATR or range value expressed in ticks — the minimum price increment for the instrument. Useful for instruments where traders think in tick-based terms such as ES (0.25 per tick) or NQ.

Points (toggleable) The ATR or range value expressed in points — the raw price unit of the instrument. For ES this is dollars-per-contract divided by the multiplier; for NQ it reflects the index point value.

High (toggleable) The price level the market needs to reach from the current session low to complete that row's range target. Calculated as: session low + ATR target. Updates live as the session low changes.

Low (toggleable) The price level the market needs to reach from the current session high to complete that row's range target. Calculated as: session high − ATR target. Updates live as the session high changes.

Status A color-coded cell showing whether each range threshold has been OVER (red) or UNDER (green). For the LIVE TR row, the status cell displays the current percentage of the ATR consumed, turning yellow at 80% and red at 100%+.

[b]Settings[/b]

[i]ATR Settings[/i]
1. ATR Period The lookback period used to calculate the Average True Range. Default is 5. Accepts values from 1 to 500.
2. ATR Smoothing The smoothing method applied to the true range values when calculating the ATR. Options to select include RMA, SMA, EMA, and WMA.
3. Live TR Mode Controls how the current session's live range is calculated. Options include Session Range (measures the high minus low of the current daily bar from the 18:00 EST session open. No overnight gap is included) and True Range (includes the overnight gap from the previous session's close, calculated as max(session high, prev close) − min(session low, prev close).

[i]Display Settings[/i]
1. Show ATR Table: Toggles the entire table on or off.
2. Show Ticks Column: Toggles the Ticks column on or off.
3. Show Points Column: Toggles the Points column on or off.
4. Show High Column: Toggles the High threshold price column on or off.
5. Show Low Column: Toggles the Low threshold price column on or off.
6. Table Position: Sets the position of the table on the chart. Nine positions available: top left, top center, top right, middle left, middle center, middle right, bottom left, bottom center, bottom right.
7. Change header background color of the header row. 
8. Change header text color of the header row. 
9. Change ATR background color of the first (label) column cells — DAILY ATR, percentage rows, and LIVE TR. 
10. Change data background color of all data cells — Ticks, Points, High, and Low columns. 
11. Change text color of all data cells. 
12. Adjust font size of all text in the table. Options are tiny, small, normal, large, and huge. 
13. Show Percentage 1 Row: Enables the first optional ATR percentage row.
14. Show Percentage 2 Row: Enables the second optional ATR percentage row.

[i]Alert Settings[/i]
1. Configurable through TradingView: Alerts can be setup for Daily ATR Exceeded, Percentage 1 ATR Exceeded, and Percentage 2 ATR Exceeded.

[b]Risk Disclaimer[/b]

This indicator is for educational and informational purposes only and does not constitute financial advice. All trading and investment decisions remain solely the responsibility of the user.

Trading involves a high degree of risk, and past performance is not indicative of future results.

Always conduct your own research and consult with a qualified financial professional before making any trading decisions.

By using this indicator, users acknowledge they understand these risks and accept full responsibility for their trading decisions and outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pogiest

//@version=6
indicator("Daily ATR [Pogiest]", overlay=true)

/// Inputs
/// ATR Settings
atr_period = input.int(5, title="ATR Period", minval=1, maxval=500, group="ATR Settings")
smoothing_type = input.string("RMA", title="ATR Smoothing", options=["RMA", "SMA", "EMA", "WMA"], group="ATR Settings")
tr_mode = input.string("Session Range", title="Live TR Mode", options=["Session Range", "True Range (inc. Gap)"], group="ATR Settings", tooltip="Session Range: measures high minus low from the 18:00 EST session open — no gap included.\nTrue Range (inc. Gap): includes the overnight gap from the previous session's close, using max(high, prev_close) - min(low, prev_close).")

/// Display Options
showTable   = input.bool(true,  title="Show ATR Table",       group="Display Options")
showTicks   = input.bool(true,  title="Show Ticks Column",    group="Display Options")
showPoints  = input.bool(true,  title="Show Points Column",   group="Display Options")
showHigh    = input.bool(true,  title="Show High Column",     group="Display Options")
showLow     = input.bool(true,  title="Show Low Column",      group="Display Options")
table_position = input.string("top_right", "Table Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group="Display Options")
header_bg_color    = input.color(color.blue,  "Header Background Color", group="Display Options")
header_text_color  = input.color(color.white, "Header Text Color",       group="Display Options")
atr_label_bg_color = input.color(color.gray,  "ATR Background Color",    group="Display Options")
row_bg_color       = input.color(color.gray,  "Data Background Color",   group="Display Options")
text_color         = input.color(color.white, "Text Color",              group="Display Options")
font_size = input.string("tiny", "Font Size", options=["tiny", "small", "normal", "large", "huge"], group="Display Options")
showPercent1 = input.bool(false, title="Show Percentage 1 Row", group="Display Options")
percent1     = input.float(50.0, title="Percentage 1 (%)", minval=0.1, maxval=100.0, step=0.1, group="Display Options")
showPercent2 = input.bool(false, title="Show Percentage 2 Row", group="Display Options")
percent2     = input.float(75.0, title="Percentage 2 (%)", minval=0.1, maxval=100.0, step=0.1, group="Display Options")

/// Calculate smoothed ATR using selected method
f_atr(length, smoothing) =>
    tr_val = ta.tr
    result = switch smoothing
        "RMA" => ta.rma(tr_val, length)
        "SMA" => ta.sma(tr_val, length)
        "EMA" => ta.ema(tr_val, length)
        "WMA" => ta.wma(tr_val, length)
        => ta.rma(tr_val, length)
    result

/// Daily ATR via security call
daily_atr  = request.security(syminfo.tickerid, "D", f_atr(atr_period, smoothing_type))
daily_high = request.security(syminfo.tickerid, "D", high)
daily_low  = request.security(syminfo.tickerid, "D", low)

/// Previous daily close for gap component (last confirmed daily close)
prev_daily_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

/// Today's TR based on selected mode
current_tr         = tr_mode == "True Range (inc. Gap)" ? math.max(daily_high, prev_daily_close) - math.min(daily_low, prev_daily_close) : daily_high - daily_low
current_tr_percent = (current_tr / daily_atr) * 100
atr_exceeded       = current_tr >= daily_atr

tick_size   = syminfo.mintick
atr_ticks   = daily_atr / tick_size
atr_points  = daily_atr
tr_ticks    = current_tr / tick_size
tr_points   = current_tr

percent1_value  = atr_ticks  * (percent1 / 100)
percent2_value  = atr_ticks  * (percent2 / 100)
percent1_points = atr_points * (percent1 / 100)
percent2_points = atr_points * (percent2 / 100)

atr_ticks_rounded       = math.ceil(atr_ticks)
percent1_rounded        = math.ceil(percent1_value)
percent2_rounded        = math.ceil(percent2_value)
atr_points_rounded      = math.ceil(atr_points      / tick_size) * tick_size
percent1_points_rounded = math.ceil(percent1_points  / tick_size) * tick_size
percent2_points_rounded = math.ceil(percent2_points  / tick_size) * tick_size
tr_ticks_rounded        = math.ceil(tr_ticks)
tr_points_rounded       = math.ceil(tr_points        / tick_size) * tick_size
current_tr_percent_rounded = math.round(current_tr_percent, 1)

/// Threshold prices
atr_target_from_low  = math.round((daily_low  + daily_atr)                    / tick_size) * tick_size
atr_target_from_high = math.round((daily_high - daily_atr)                    / tick_size) * tick_size
p1_target_from_low   = math.round((daily_low  + daily_atr * (percent1 / 100)) / tick_size) * tick_size
p1_target_from_high  = math.round((daily_high - daily_atr * (percent1 / 100)) / tick_size) * tick_size
p2_target_from_low   = math.round((daily_low  + daily_atr * (percent2 / 100)) / tick_size) * tick_size
p2_target_from_high  = math.round((daily_high - daily_atr * (percent2 / 100)) / tick_size) * tick_size
tr_target_from_low   = math.round((daily_low  + current_tr)                   / tick_size) * tick_size
tr_target_from_high  = math.round((daily_high - current_tr)                   / tick_size) * tick_size

/// ── ALERTS ──────────────────────────────────────────────────────────────────
/// Fire once on the bar where each threshold is first crossed (crossover)
/// Use ta.crossover so alerts only trigger on the transition to OVER, not every bar

atr_cross    = ta.crossover(current_tr, daily_atr)
p1_cross     = ta.crossover(current_tr, daily_atr * (percent1 / 100))
p2_cross     = ta.crossover(current_tr, daily_atr * (percent2 / 100))

alertcondition(atr_cross, title="Daily ATR Exceeded",
  message="Daily ATR Exceeded — Live range has crossed over the full Daily ATR.")

alertcondition(p1_cross, title="Percentage 1 ATR Exceeded",
  message="Percentage 1 ATR Exceeded — Live range has crossed over the Percentage 1 ATR threshold.")

alertcondition(p2_cross, title="Percentage 2 ATR Exceeded",
  message="Percentage 2 ATR Exceeded — Live range has crossed over the Percentage 2 ATR threshold.")

/// Convert table position string to position enum
pos = position.top_center
switch table_position
    "top_left"      => pos := position.top_left
    "top_center"    => pos := position.top_center
    "top_right"     => pos := position.top_right
    "middle_left"   => pos := position.middle_left
    "middle_center" => pos := position.middle_center
    "middle_right"  => pos := position.middle_right
    "bottom_left"   => pos := position.bottom_left
    "bottom_center" => pos := position.bottom_center
    "bottom_right"  => pos := position.bottom_right

fs = size.small
switch font_size
    "tiny"   => fs := size.tiny
    "small"  => fs := size.small
    "normal" => fs := size.normal
    "large"  => fs := size.large
    "huge"   => fs := size.huge

/// Colors
col_header_bg   = header_bg_color
col_header_text = header_text_color
col_body_bg     = row_bg_color
col_label_bg    = atr_label_bg_color
col_body_text   = text_color
col_exceeded_bg = color.rgb(180, 30, 30)
col_within_bg   = color.rgb(30, 140, 30)
col_status_text = color.white

/// Dynamic column indices
c_ticks  = 1
c_points = 1 + (showTicks  ? 1 : 0)
c_high   = 1 + (showTicks  ? 1 : 0) + (showPoints ? 1 : 0)
c_low    = 1 + (showTicks  ? 1 : 0) + (showPoints ? 1 : 0) + (showHigh   ? 1 : 0)
c_status = 1 + (showTicks  ? 1 : 0) + (showPoints ? 1 : 0) + (showHigh   ? 1 : 0) + (showLow    ? 1 : 0)
total_cols = 2 + (showTicks ? 1 : 0) + (showPoints ? 1 : 0) + (showHigh  ? 1 : 0) + (showLow    ? 1 : 0)

var tbl = table(na)

if barstate.islast and showTable
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(pos, total_cols, 5, frame_color=color.black, frame_width=2, border_color=color.black, border_width=1)

    // ── HEADER ROW ──────────────────────────────────────────────────────────
    table.cell(tbl, 0, 0, "Range (" + smoothing_type + " " + str.tostring(atr_period) + ")",
      text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)
    if showTicks
        table.cell(tbl, c_ticks, 0, "Ticks",
          text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)
    if showPoints
        table.cell(tbl, c_points, 0, "Points",
          text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)
    if showHigh
        table.cell(tbl, c_high, 0, "High",
          text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)
    if showLow
        table.cell(tbl, c_low, 0, "Low",
          text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)
    table.cell(tbl, c_status, 0, "Status",
      text_color=col_header_text, bgcolor=col_header_bg, text_size=fs, text_halign=text.align_center)

    // ── ROW 1: Daily ATR ────────────────────────────────────────────────────
    atr_status_text = atr_exceeded ? "OVER" : "UNDER"
    atr_status_bg   = atr_exceeded ? col_exceeded_bg : col_within_bg
    table.cell(tbl, 0, 1, "DAILY ATR",
      text_color=col_body_text, bgcolor=col_label_bg, text_size=fs, text_halign=text.align_center)
    if showTicks
        table.cell(tbl, c_ticks, 1, str.tostring(atr_ticks_rounded),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showPoints
        table.cell(tbl, c_points, 1, str.tostring(atr_points_rounded),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showHigh
        table.cell(tbl, c_high, 1, str.tostring(atr_target_from_low),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showLow
        table.cell(tbl, c_low, 1, str.tostring(atr_target_from_high),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    table.cell(tbl, c_status, 1, atr_status_text,
      text_color=col_status_text, bgcolor=atr_status_bg, text_size=fs, text_halign=text.align_center)

    current_row = 2

    // ── Percentage rows ──────────────────────────────────────────────────────
    if showPercent1
        p1_exceeded    = current_tr >= daily_atr * (percent1 / 100)
        p1_status_text = p1_exceeded ? "OVER" : "UNDER"
        p1_status_bg   = p1_exceeded ? col_exceeded_bg : col_within_bg
        table.cell(tbl, 0, current_row, str.tostring(percent1) + "% ATR",
          text_color=col_body_text, bgcolor=col_label_bg, text_size=fs, text_halign=text.align_center)
        if showTicks
            table.cell(tbl, c_ticks, current_row, str.tostring(percent1_rounded),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showPoints
            table.cell(tbl, c_points, current_row, str.tostring(percent1_points_rounded),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showHigh
            table.cell(tbl, c_high, current_row, str.tostring(p1_target_from_low),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showLow
            table.cell(tbl, c_low, current_row, str.tostring(p1_target_from_high),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        table.cell(tbl, c_status, current_row, p1_status_text,
          text_color=col_status_text, bgcolor=p1_status_bg, text_size=fs, text_halign=text.align_center)
        current_row += 1

    if showPercent2
        p2_exceeded    = current_tr >= daily_atr * (percent2 / 100)
        p2_status_text = p2_exceeded ? "OVER" : "UNDER"
        p2_status_bg   = p2_exceeded ? col_exceeded_bg : col_within_bg
        table.cell(tbl, 0, current_row, str.tostring(percent2) + "% ATR",
          text_color=col_body_text, bgcolor=col_label_bg, text_size=fs, text_halign=text.align_center)
        if showTicks
            table.cell(tbl, c_ticks, current_row, str.tostring(percent2_rounded),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showPoints
            table.cell(tbl, c_points, current_row, str.tostring(percent2_points_rounded),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showHigh
            table.cell(tbl, c_high, current_row, str.tostring(p2_target_from_low),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        if showLow
            table.cell(tbl, c_low, current_row, str.tostring(p2_target_from_high),
              text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
        table.cell(tbl, c_status, current_row, p2_status_text,
          text_color=col_status_text, bgcolor=p2_status_bg, text_size=fs, text_halign=text.align_center)
        current_row += 1

    // ── LAST ROW: LIVE TR ────────────────────────────────────────────────────
    tr_pct_bg   = atr_exceeded ? col_exceeded_bg : current_tr_percent >= 80 ? color.rgb(180, 150, 0) : col_body_bg
    tr_pct_text = atr_exceeded or current_tr_percent >= 80 ? color.white : col_body_text
    table.cell(tbl, 0, current_row, "LIVE TR",
      text_color=col_body_text, bgcolor=col_label_bg, text_size=fs, text_halign=text.align_center)
    if showTicks
        table.cell(tbl, c_ticks, current_row, str.tostring(tr_ticks_rounded),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showPoints
        table.cell(tbl, c_points, current_row, str.tostring(tr_points_rounded),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showHigh
        table.cell(tbl, c_high, current_row, str.tostring(tr_target_from_low),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    if showLow
        table.cell(tbl, c_low, current_row, str.tostring(tr_target_from_high),
          text_color=col_body_text, bgcolor=col_body_bg, text_size=fs, text_halign=text.align_center)
    table.cell(tbl, c_status, current_row, str.tostring(current_tr_percent_rounded) + "%",
      text_color=tr_pct_text, bgcolor=tr_pct_bg, text_size=fs, text_halign=text.align_center)

else if not na(tbl)
    table.delete(tbl)
    tbl := table(na)
````
