# MS Dashboard - CDH

- url: https://www.tradingview.com/script/2dJ9ioDl-MS-Dashboard-CDH/
- type: indicator
- pine_id: PUB;5e871949d7cb4994942fb5d9aa502b98
- version: 1.0

## Description

MS Dashboard - CDH
Dashboard for quick reference to market structure in the form of a dashboard.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlexFuch

//@version=6

indicator("Money Flow Dashboard", shorttitle = "MFD", overlay = true, scale = scale.none, dynamic_requests = true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* BAR SETTINGS *//

paint_bars = input(false, title = "Paint Bars?", group = 'Bar Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TABLE SETTINGS *//

dashboard_position  = input.session("Middle Right", "Posision", ["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Top Center", "Bottom Center", "Middle Right"], group = 'Table Settings')
text_size = input.session('Normal', "Size", options = ["Tiny", "Small", "Normal", "Large"], group = 'Table Settings')
text_color = input(#d1d4dc, title = "Text Color", group = 'Table Settings')
table_color = input(color.gray, title = "Border Color", group = 'Table Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CONTENT SETTINGS *//

show_actual_value = input(true, title = "Show Actual Value?", group = 'Content Settings')
green_indicator = input("🟢", title = "Above Zero Indicator", group = 'Content Settings')
red_indicator = input("🔴", title = "Below Zero Indicator", group = 'Content Settings')

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* MONEY FLOW *//

money_flow_multiplier = input.int(205, "Multiplier", minval = 1, maxval = 500, step = 10, group = "Money Flow Settings")
money_flow_ma_length = input.int(59, "MA's Length", minval = 1, maxval = 900, group = "Money Flow Settings")

mf(ha_open, ha_close, ha_high, ha_low) =>
    candle_value = (ha_close - ha_open) / (ha_high - ha_low)
    src = candle_value * (money_flow_multiplier + 1)
    result = src
    if money_flow_ma_length > 1
        result := ta.sma(src, money_flow_ma_length)
    result

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TIMEFRAME SETTINGS *//

show_1m = input(true, title = 'Show 1m', group = 'Timeframe Settings')
show_2m = input(false, title = 'Show 2m ', group = 'Timeframe Settings')
show_3m = input(true, title = 'Show 3m ', group = 'Timeframe Settings')
show_6m = input(true, title = 'Show 5m', group = 'Timeframe Settings')
show_10m = input(false, title = 'Show 10m', group = 'Timeframe Settings')
show_15m = input(true, title = 'Show 15m', group = 'Timeframe Settings')
show_36m = input(false, title = 'Show 30m', group = 'Timeframe Settings')
show_45m = input(false, title = 'Show 45m', group = 'Timeframe Settings')
show_1h = input(true, title = 'Show 1h', group = 'Timeframe Settings')
show_2h = input(false, title = 'Show 2h', group = 'Timeframe Settings')
show_3h = input(false, title = 'Show 3h', group = 'Timeframe Settings')
show_4h = input(true, title = 'Show 4h', group = 'Timeframe Settings')
show_12h = input(false, title = 'Show 12h', group = 'Timeframe Settings')
show_D = input(true, title = 'Show D', group = 'Timeframe Settings')
show_3D = input(false, title = 'Show 3D', group = 'Timeframe Settings')
show_W = input(false, title = 'Show W', group = 'Timeframe Settings')
show_M = input(false, title = 'Show M', group = 'Timeframe Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CALCULATION *//

var table_position = dashboard_position == 'Top Right' ? position.top_right :
  dashboard_position == 'Top Left' ? position.top_left :
  dashboard_position == 'Top Center' ? position.top_center :
  dashboard_position == 'Bottom Right' ? position.bottom_right :
  dashboard_position == 'Bottom Left' ? position.bottom_left :
  dashboard_position == 'Bottom Center' ? position.bottom_center :
  dashboard_position == 'Middle Right' ? position.middle_right :
  dashboard_position == 'Middle Left' ? position.middle_left : position.middle_right

var table_text_size = text_size == 'Normal' ? size.normal :
  text_size == 'Large' ? size.large :
  text_size == 'Tiny' ? size.tiny :
  text_size == 'Small' ? size.small : size.normal

var t = table.new(position = table_position,
                  columns = show_actual_value ? 3 : 2,
                  rows = 20,
                  frame_color = table_color,
                  frame_width = 2,
                  border_color = table_color,
                  border_width = 2)

status(value) =>
    value > 0 ? green_indicator : red_indicator

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TABLE *//

float result_1m = na
if show_1m
    result_1m := request.security(ticker.heikinashi(syminfo.tickerid), "1", mf(open, close, high, low))

float result_2m = na
if show_2m
    result_2m := request.security(ticker.heikinashi(syminfo.tickerid), "2", mf(open, close, high, low))

float result_3m = na
if show_3m
    result_3m := request.security(ticker.heikinashi(syminfo.tickerid), "3", mf(open, close, high, low))

float result_5m = na
if show_6m
    result_5m := request.security(ticker.heikinashi(syminfo.tickerid), "5", mf(open, close, high, low))

float result_10m = na
if show_10m
    result_10m := request.security(ticker.heikinashi(syminfo.tickerid), "10", mf(open, close, high, low))

float result_15m = na
if show_15m
    result_15m := request.security(ticker.heikinashi(syminfo.tickerid), "15", mf(open, close, high, low))

float result_36m = na
if show_36m
    result_36m := request.security(ticker.heikinashi(syminfo.tickerid), "30", mf(open, close, high, low))

float result_45m = na
if show_45m
    result_45m := request.security(ticker.heikinashi(syminfo.tickerid), "45", mf(open, close, high, low))

float result_1h = na
if show_1h
    result_1h := request.security(ticker.heikinashi(syminfo.tickerid), "60", mf(open, close, high, low))

float result_2h = na
if show_2h
    result_2h := request.security(ticker.heikinashi(syminfo.tickerid), "120", mf(open, close, high, low))

float result_3h = na
if show_3h
    result_3h := request.security(ticker.heikinashi(syminfo.tickerid), "180", mf(open, close, high, low))

float result_4h = na
if show_4h
    result_4h := request.security(ticker.heikinashi(syminfo.tickerid), "240", mf(open, close, high, low))

float result_12h = na
if show_12h
    result_12h := request.security(ticker.heikinashi(syminfo.tickerid), "720", mf(open, close, high, low))

float result_D = na
if show_D
    result_D := request.security(ticker.heikinashi(syminfo.tickerid), "D", mf(open, close, high, low))

float result_3D = na
if show_3D
    result_3D := request.security(ticker.heikinashi(syminfo.tickerid), "3D", mf(open, close, high, low))

float result_W = na
if show_W
    result_W := request.security(ticker.heikinashi(syminfo.tickerid), "W", mf(open, close, high, low))

float result_M = na
if show_M
    result_M := request.security(ticker.heikinashi(syminfo.tickerid), "M", mf(open, close, high, low))

if (barstate.islast)
    if (show_1m)
        table.cell(t, 0, 0, "1m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 0, status(result_1m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 0, str.tostring(math.round(result_1m)), text_color = text_color, text_size = table_text_size)

    if (show_2m)
        table.cell(t, 0, 1, "2m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 1, status(result_2m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 1, str.tostring(math.round(result_2m)), text_color = text_color, text_size = table_text_size)

    if (show_3m)
        table.cell(t, 0, 2, "3m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 2, status(result_3m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 2, str.tostring(math.round(result_3m)), text_color = text_color, text_size = table_text_size)

    if (show_6m)
        table.cell(t, 0, 3, "5m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 3, status(result_5m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 3, str.tostring(math.round(result_5m)), text_color = text_color, text_size = table_text_size)

    if (show_10m)
        table.cell(t, 0, 4, "10m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 4, status(result_10m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 4, str.tostring(math.round(result_10m)), text_color = text_color, text_size = table_text_size)

    if (show_15m)
        table.cell(t, 0, 5, "15m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 5, status(result_15m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 5, str.tostring(math.round(result_15m)), text_color = text_color, text_size = table_text_size)

    if (show_36m)
        table.cell(t, 0, 6, "30m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 6, status(result_36m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 6, str.tostring(math.round(result_36m)), text_color = text_color, text_size = table_text_size)

    if (show_45m)
        table.cell(t, 0, 7, "45m", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 7, status(result_45m), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 7, str.tostring(math.round(result_45m)), text_color = text_color, text_size = table_text_size)

    if (show_1h)
        table.cell(t, 0, 8, "1h", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 8, status(result_1h), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 8, str.tostring(math.round(result_1h)), text_color = text_color, text_size = table_text_size)

    if (show_2h)
        table.cell(t, 0, 9, "2h", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 9, status(result_2h), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 9, str.tostring(math.round(result_2h)), text_color = text_color, text_size = table_text_size)

    if (show_3h)
        table.cell(t, 0, 10, "3h", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 10, status(result_3h), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 10, str.tostring(math.round(result_3h)), text_color = text_color, text_size = table_text_size)

    if (show_4h)
        table.cell(t, 0, 11, "4h", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 11, status(result_4h), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 11, str.tostring(math.round(result_4h)), text_color = text_color, text_size = table_text_size)

    if (show_12h)
        table.cell(t, 0, 12, "12h", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 12, status(result_12h), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 12, str.tostring(math.round(result_12h)), text_color = text_color, text_size = table_text_size)

    if (show_D)
        table.cell(t, 0, 13, "D", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 13, status(result_D), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 13, str.tostring(math.round(result_D)), text_color = text_color, text_size = table_text_size)

    if (show_3D)
        table.cell(t, 0, 14, "3D", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 14, status(result_3D), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 14, str.tostring(math.round(result_3D)), text_color = text_color, text_size = table_text_size)

    if (show_W)
        table.cell(t, 0, 15, "W", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 15, status(result_W), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 15, str.tostring(math.round(result_W)), text_color = text_color, text_size = table_text_size)

    if (show_M)
        table.cell(t, 0, 16, "M", text_color = text_color, text_size = table_text_size)
        table.cell(t, 1, 16, status(result_M), text_color = text_color, text_size = table_text_size)
        if (show_actual_value)
            table.cell(t, 2, 16, str.tostring(math.round(result_M)), text_color = text_color, text_size = table_text_size)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* BARS *//

current_timeframe = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, mf(open, close, high, low))
current_timeframe_prev = current_timeframe[1]
barcolor = current_timeframe > 0 ? color.green : color.red
barcolor(color = barcolor, display = paint_bars ? display.all : display.none)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* ALERTS *//

alertcondition((current_timeframe > 0 and current_timeframe_prev < 0) or (current_timeframe < 0 and current_timeframe_prev > 0), '0. Cross zero line', '⏰ Cross on {{ticker}}:{{interval}}min')
alertcondition(current_timeframe > 0 and current_timeframe_prev < 0, '1. Cross up', '🟢 Cross up on {{ticker}}:{{interval}}min')
alertcondition(current_timeframe < 0 and current_timeframe_prev > 0, '2. Cross down', '🔴 Cross down on {{ticker}}:{{interval}}min')
alertcondition(status(result_W) == status(result_D) and status(result_D) == status(result_4h), '3. W, D, 4h aligned', 'W, D, 4h {{ticker}} MF alignment')
alertcondition(status(result_D) == status(result_4h) and status(result_4h) == status(result_1h), '4. D, 4h, 1h aligned', 'D, 4h, 1h {{ticker}} MF alignment')
alertcondition(status(result_4h) == status(result_1h) and status(result_1h) == status(result_15m), '5. 4h, 1h, 15m aligned', '4h, 1h, 15m {{ticker}} MF alignment')
alertcondition(status(result_1h) == status(result_15m) and status(result_15m) == status(result_5m), '6. 1h, 15m, 5m aligned', '1h, 15m, 5m {{ticker}} MF alignment')
alertcondition(status(result_15m) == status(result_5m) and status(result_5m) == status(result_3m), '7. 15m, 5m, 3m aligned', '15m, 5m, 3m {{ticker}} MF alignment')
alertcondition(status(result_5m) == status(result_3m) and status(result_3m) == status(result_1m), '8. 5m, 3m, 1m aligned', '5m, 3m, 1m {{ticker}} MF alignment')
````
