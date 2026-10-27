# VA Look-back Proximity zones

- url: https://www.tradingview.com/script/4U0AEOXV-VA-Look-back-Proximity-zones/
- type: indicator
- pine_id: PUB;0dd10b8016764814bfdb10d692b5d3fc
- version: 1.0

## Description

It's a market profile indicator that draws a value area (VAH/VAL/POC) over a configurable look back window, and adds a "VAZ" filter that tells you where current price sits inside that value area — long zone (near VAL), short zone (near VAH), or dead/grey (in the middle, or outside the range entirely). The zone colors the info box, the candles, and a full-height vertical line at the current bar.

## Source Code

````pine
//@version=6
indicator('VA LOOKBACK [Auto, Bars Back, Anchored, Fixed/Visible Range, Periodic]', shorttitle = 'VA LOOKBACK', overlay = true, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

mode = input.string('Auto Lookback', 'Mode', options = ['Auto Lookback', 'Bars Back', 'Fixed Range', 'Anchor', 'Visible Region', 'Periodic'])
bars_back = input.int(200, 'Bars Back (manual mode)', minval = 10, maxval = 5000)
start_time = input.time(timestamp('2025-06-01 00:00'), 'Start Time')
end_time = input.time(timestamp('2025-06-30 23:59'), 'End Time')
block_time = input.timeframe('30', 'Block Time', tooltip = 'Timeframe for TPO blocks (e.g., 30 for 30min blocks)')

// ─── Auto Lookback Presets ──────────────────────────────────────────────
auto_d1  = input.string('None',    'D1 alternate (default: 2 months / 60 bars)',  options = ['None', '3 months'],            group = 'Auto Lookback Presets')
auto_h12 = input.string('None',    'H12 alternate (default: 45 days / 90 bars)',  options = ['None', '60 days'],             group = 'Auto Lookback Presets')
auto_h4  = input.string('30 days', 'H4 alternate (default: 7 days / 42 bars)',    options = ['None', '15 days', '30 days'],  group = 'Auto Lookback Presets')
auto_h1  = input.string('15 days', 'H1 alternate (default: 7 days / 168 bars)',   options = ['None', '15 days'],             group = 'Auto Lookback Presets')
auto_m15 = input.string('3 days',  'M15 alternate (default: 2 days / 192 bars)',  options = ['None', '3 days', '4 days'],    group = 'Auto Lookback Presets')
auto_m5  = input.string('None',    'M5 alternate (default: 24 hours / 288 bars)', options = ['None', '36 hours'],            group = 'Auto Lookback Presets')

// ─── Info Box ──────────────────────────────────────────────────────────
show_info_box    = input.bool(true,        'Show Info Box',           group = 'Info Box')
info_box_pos     = input.string('Top Right','Info Box Position',      options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = 'Info Box')
info_box_size    = input.string('tiny',    'Info Box Text Size',      options = ['auto', 'tiny', 'small', 'normal', 'large'], tooltip = 'auto = scales with chart zoom (smallest)', group = 'Info Box')
info_box_compact = input.bool(true,        'Compact Layout',          tooltip = 'One column instead of two, labels abbreviated (TF/P/B)', group = 'Info Box')
info_box_mono    = input.bool(false,       'Use Monospace Font',      tooltip = 'Monospace is wider; turn off for tighter box', group = 'Info Box')
info_box_border  = input.bool(false,       'Show Border',             group = 'Info Box')
info_box_bg      = input.color(color.new(color.black, 30), 'Background Color', group = 'Info Box')

// ─── VA Zone Filter (VAZ) ──────────────────────────────────────────────
vaz_enable        = input.bool(true,  'Enable VAZ',                          group = 'VA Zone Filter (VAZ)')
vaz_long_max_pct  = input.float(40.0, 'Long Max Range %',  minval = 10, maxval = 50, step = 5, tooltip = 'Price within X% of VAL = long zone', group = 'VA Zone Filter (VAZ)')
vaz_short_min_pct = input.float(60.0, 'Short Min Range %', minval = 50, maxval = 90, step = 5, tooltip = 'Price above X% of range = short zone', group = 'VA Zone Filter (VAZ)')
vaz_color_infobox = input.bool(true,  'Color Info Box by Zone',              group = 'VA Zone Filter (VAZ)')
vaz_color_bars    = input.bool(true,  'Color Bars by Zone',                  tooltip = 'Tints candle color based on current zone', group = 'VA Zone Filter (VAZ)')
vaz_show_vline    = input.bool(true,  'Show Vertical Line (full chart)',     tooltip = 'Vertical line at current bar spanning entire chart height', group = 'VA Zone Filter (VAZ)')
vaz_vline_width   = input.int(2, 'Vertical Line Width', minval = 1, maxval = 5, group = 'VA Zone Filter (VAZ)')
vaz_vline_style   = input.string('Solid', 'Vertical Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'VA Zone Filter (VAZ)')
vaz_long_color    = input.color(color.new(#90EE90, 30), 'Long Zone Color',  tooltip = 'Light green', group = 'VA Zone Filter (VAZ)')
vaz_short_color   = input.color(color.new(#FFB3B3, 30), 'Short Zone Color', tooltip = 'Light red',   group = 'VA Zone Filter (VAZ)')
vaz_dead_color    = input.color(color.new(#D3D3D3, 30), 'Dead Zone Color',  tooltip = 'Light grey',  group = 'VA Zone Filter (VAZ)')
vaz_show_bg       = input.bool(false, 'Show Zone Background Highlight',      group = 'VA Zone Filter (VAZ)')

// ─── Periodic Mode ─────────────────────────────────────────────────────
period_type         = input.string('Daily', 'Period Type', options = ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Monthly OPEX', 'Quarterly OPEX'], group = 'Periodic Mode')
periods_count       = input.int(5, 'Number of Periods', minval = 1, maxval = 20, group = 'Periodic Mode')
show_current_period = input.bool(false, 'Show Current Period', group = 'Periodic Mode')

// ─── Profile Calc ──────────────────────────────────────────────────────
tpo_levels         = input.int(64, 'TPO Levels', minval = 5, maxval = 200)
show_poc           = input.bool(false, 'Show POC')
show_value_area    = input.bool(false, 'Show Value Area')
value_area_pct     = input.float(70.0, 'Value Area %', minval = 50, maxval = 95)
show_vah_val_lines = input.bool(true, 'Show VAH/VAL Lines')
show_single_prints = input.bool(false, 'Show Single Prints')
single_print_style = input.string('Lines', 'Single Print Style', options = ['Lines', 'Boxes'])
show_tpo_boxes     = input.bool(false, 'Show TPO Boxes (sideways profile)', tooltip = 'Disable for cleaner level-only view')

// ─── Colors ────────────────────────────────────────────────────────────
tpo_color          = input.color(color.new(color.blue, 60), 'TPO Color')
poc_color          = input.color(color.blue, 'POC Color')
va_color           = input.color(color.new(color.yellow, 80), 'Value Area Color')
vah_color          = input.color(color.red, 'VAH Color')
val_color          = input.color(color.green, 'VAL Color')
single_print_color = input.color(color.purple, 'Single Print Color')

// ─── Periodic Open/Close + IB ──────────────────────────────────────────
show_open_close = input.bool(false, 'Show Open/Close Lines', group = 'Periodic Mode')
open_color      = input.color(color.blue, 'Open Color', group = 'Periodic Mode')
close_color     = input.color(color.orange, 'Close Color', group = 'Periodic Mode')
oc_line_style   = input.string('Dashed', 'Open/Close Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Periodic Mode')
oc_line_width   = input.int(1, 'Open/Close Line Width', minval = 1, maxval = 5, group = 'Periodic Mode')
show_ib         = input.bool(false, 'Show Initial Balance', group = 'Periodic Mode')
ib_block_count  = input.int(2, 'IB Block Count', minval = 1, maxval = 100, tooltip = 'Number of TPO blocks for Initial Balance', group = 'Periodic Mode')
ib_color        = input.color(color.white, 'IB Color', group = 'Periodic Mode')
ib_line_style   = input.string('Solid', 'IB Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Periodic Mode')
ib_line_width   = input.int(2, 'IB Line Width', minval = 1, maxval = 5, group = 'Periodic Mode')

// ─── Labels & Lines ────────────────────────────────────────────────────
showLabels        = input.bool(true, 'Show Labels', group = 'Display')
fontSize          = input.string('small', 'Font Size', options = ['tiny', 'small', 'normal', 'large', 'huge'], group = 'Display')
levelOffsetRight  = input.int(1, 'Level Offset Right', minval = 0, maxval = 10000, group = 'Display')
labelPosition     = input.string('Right', 'Label Position', options = ['Above', 'Below', 'Left', 'Right', 'Upper Right', 'Upper Left', 'Lower Right', 'Lower Left'], group = 'Display')

poc_line_style = input.string('Solid', 'POC Line Style', options = ['Solid', 'Dashed', 'Dotted'])
poc_line_width = input.int(1, 'POC Line Width', minval = 1, maxval = 5)
vah_line_style = input.string('Solid', 'VAH Line Style', options = ['Solid', 'Dashed', 'Dotted'])
vah_line_width = input.int(1, 'VAH Line Width', minval = 1, maxval = 5)
val_line_style = input.string('Solid', 'VAL Line Style', options = ['Solid', 'Dashed', 'Dotted'])
val_line_width = input.int(1, 'VAL Line Width', minval = 1, maxval = 5)

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════

getFontSize() =>
    switch fontSize
        'tiny'   => size.tiny
        'small'  => size.small
        'normal' => size.normal
        'large'  => size.large
        'huge'   => size.huge
        =>          size.normal

getInfoBoxSize() =>
    switch info_box_size
        'auto'   => size.auto
        'tiny'   => size.tiny
        'small'  => size.small
        'normal' => size.normal
        'large'  => size.large
        =>          size.tiny

getLineStyle(styleString) =>
    switch styleString
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        =>          line.style_solid

getLabelStyle() =>
    switch labelPosition
        'Above'       => label.style_label_down
        'Below'       => label.style_label_up
        'Left'        => label.style_label_right
        'Right'       => label.style_label_left
        'Upper Right' => label.style_label_lower_right
        'Upper Left'  => label.style_label_lower_left
        'Lower Right' => label.style_label_upper_right
        'Lower Left'  => label.style_label_upper_left
        =>               label.style_label_left

getInfoBoxPosition() =>
    switch info_box_pos
        'Top Right'    => position.top_right
        'Top Left'     => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Left'  => position.bottom_left
        =>                position.top_right

// ═══════════════════════════════════════════════════════════════════════════
// AUTO LOOKBACK RESOLUTION
// ═══════════════════════════════════════════════════════════════════════════

resolve_auto_lookback() =>
    chart_secs = timeframe.in_seconds(timeframe.period)

    int    out_bars   = 168
    string out_tf     = 'H1'
    string out_period = '7 days'
    bool   fallback   = false

    if chart_secs == 86400
        out_tf := 'D1'
        if auto_d1 == '3 months'
            out_bars := 90
            out_period := '3 months'
        else
            out_bars := 60
            out_period := '2 months'

    else if chart_secs == 43200
        out_tf := 'H12'
        if auto_h12 == '60 days'
            out_bars := 120
            out_period := '60 days'
        else
            out_bars := 90
            out_period := '45 days'

    else if chart_secs == 14400
        out_tf := 'H4'
        if auto_h4 == '30 days'
            out_bars := 180
            out_period := '30 days'
        else if auto_h4 == '15 days'
            out_bars := 90
            out_period := '15 days'
        else
            out_bars := 42
            out_period := '7 days'

    else if chart_secs == 3600
        out_tf := 'H1'
        if auto_h1 == '15 days'
            out_bars := 360
            out_period := '15 days'
        else
            out_bars := 168
            out_period := '7 days'

    else if chart_secs == 900
        out_tf := 'M15'
        if auto_m15 == '4 days'
            out_bars := 384
            out_period := '4 days'
        else if auto_m15 == '3 days'
            out_bars := 288
            out_period := '3 days'
        else
            out_bars := 192
            out_period := '2 days'

    else if chart_secs == 300
        out_tf := 'M5'
        if auto_m5 == '36 hours'
            out_bars := 432
            out_period := '36 hours'
        else
            out_bars := 288
            out_period := '24 hours'

    else if chart_secs <= 180
        out_tf := str.tostring(timeframe.period) + ' (→M5)'
        fallback := true
        if auto_m5 == '36 hours'
            out_bars := math.round(36 * 3600 / chart_secs)
            out_period := '36 hours'
        else
            out_bars := math.round(24 * 3600 / chart_secs)
            out_period := '24 hours'

    else if chart_secs > 300 and chart_secs < 3600
        out_tf := str.tostring(timeframe.period) + ' (→M15)'
        fallback := true
        if auto_m15 == '4 days'
            out_bars := math.round(4 * 86400 / chart_secs)
            out_period := '4 days'
        else if auto_m15 == '3 days'
            out_bars := math.round(3 * 86400 / chart_secs)
            out_period := '3 days'
        else
            out_bars := math.round(2 * 86400 / chart_secs)
            out_period := '2 days'

    else if chart_secs > 3600 and chart_secs < 14400
        out_tf := str.tostring(timeframe.period) + ' (→H1)'
        fallback := true
        if auto_h1 == '15 days'
            out_bars := math.round(15 * 86400 / chart_secs)
            out_period := '15 days'
        else
            out_bars := math.round(7 * 86400 / chart_secs)
            out_period := '7 days'

    else if chart_secs > 14400 and chart_secs < 43200
        out_tf := str.tostring(timeframe.period) + ' (→H4)'
        fallback := true
        if auto_h4 == '30 days'
            out_bars := math.round(30 * 86400 / chart_secs)
            out_period := '30 days'
        else if auto_h4 == '15 days'
            out_bars := math.round(15 * 86400 / chart_secs)
            out_period := '15 days'
        else
            out_bars := math.round(7 * 86400 / chart_secs)
            out_period := '7 days'

    else if chart_secs > 86400
        out_tf := str.tostring(timeframe.period) + ' (→D1)'
        fallback := true
        if auto_d1 == '3 months'
            out_bars := math.max(2, math.round(90 * 86400 / chart_secs))
            out_period := '3 months'
        else
            out_bars := math.max(2, math.round(60 * 86400 / chart_secs))
            out_period := '2 months'

    else
        out_tf := str.tostring(timeframe.period) + ' (?)'
        fallback := true
        out_bars := 200
        out_period := 'default'

    [out_bars, out_tf, out_period, fallback]

[auto_bars, auto_tf_label, auto_period_label, auto_fallback] = resolve_auto_lookback()
effective_bars = mode == 'Auto Lookback' ? auto_bars : bars_back

// ═══════════════════════════════════════════════════════════════════════════
// VAZ STATE (populated after main profile draws)
// ═══════════════════════════════════════════════════════════════════════════

var float vaz_vah     = na
var float vaz_val     = na
var float vaz_range_pct = na
var bool  vaz_long_zone  = false
var bool  vaz_short_zone = false
var bool  vaz_dead_zone  = false
var line  vaz_vert_line  = na

// ═══════════════════════════════════════════════════════════════════════════
// SECURITY DATA
// ═══════════════════════════════════════════════════════════════════════════

[block_high, block_low, block_time_stamp] = request.security(syminfo.tickerid, block_time, [high, low, time], lookahead = barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════════════
// PERIODIC HELPERS
// ═══════════════════════════════════════════════════════════════════════════

get_third_friday(year, month) =>
    first_day = timestamp(year, month, 1, 0, 0, 0)
    first_weekday = dayofweek(first_day)
    days_to_friday = first_weekday <= dayofweek.friday ? dayofweek.friday - first_weekday : 7 - (first_weekday - dayofweek.friday)
    third_friday_day = 1 + days_to_friday + 14
    timestamp(year, month, third_friday_day, 16, 0, 0)

get_quarterly_opex_month(year, month) =>
    if month <= 3
        [year, 3]
    else if month <= 6
        [year, 6]
    else if month <= 9
        [year, 9]
    else
        [year, 12]

get_previous_quarterly_opex_month(year, month) =>
    if month <= 3
        [year - 1, 12]
    else if month <= 6
        [year, 3]
    else if month <= 9
        [year, 6]
    else
        [year, 9]

get_opex_start(year, month) =>
    prev_month = month == 1 ? 12 : month - 1
    prev_year = month == 1 ? year - 1 : year
    prev_opex = get_third_friday(prev_year, prev_month)
    prev_opex + 86400000

get_next_opex_start(year, month) =>
    next_month = month == 12 ? 1 : month + 1
    next_year = month == 12 ? year + 1 : year
    get_third_friday(next_year, next_month) + 86400000

get_quarterly_opex_start(year, month) =>
    [prev_year, prev_month] = get_previous_quarterly_opex_month(year, month)
    prev_opex = get_third_friday(prev_year, prev_month)
    prev_opex + 86400000

get_next_quarterly_opex_start(year, month) =>
    [current_year, current_month] = get_quarterly_opex_month(year, month)
    next_quarter_month = current_month == 12 ? 3 : current_month + 3
    next_quarter_year = current_month == 12 ? current_year + 1 : current_year
    get_third_friday(next_quarter_year, next_quarter_month) + 86400000

get_period_start(period_type, t) =>
    year = year(t)
    month = month(t)
    day = dayofmonth(t)
    week_day = dayofweek(t)
    switch period_type
        'Daily' =>
            timestamp(year, month, day, 0, 0, 0)
        'Weekly' =>
            days_from_monday = week_day == dayofweek.sunday ? 6 : week_day - dayofweek.monday
            timestamp(year, month, day - days_from_monday, 0, 0, 0)
        'Monthly' =>
            timestamp(year, month, 1, 0, 0, 0)
        'Quarterly' =>
            quarter_month = month <= 3 ? 1 : month <= 6 ? 4 : month <= 9 ? 7 : 10
            timestamp(year, quarter_month, 1, 0, 0, 0)
        'Monthly OPEX' =>
            get_opex_start(year, month)
        'Quarterly OPEX' =>
            get_quarterly_opex_start(year, month)
        => t

get_period_end(period_type, period_start) =>
    year = year(period_start)
    month = month(period_start)
    day = dayofmonth(period_start)
    switch period_type
        'Daily' =>
            timestamp(year, month, day, 23, 59, 59)
        'Weekly' =>
            timestamp(year, month, day + 6, 23, 59, 59)
        'Monthly' =>
            next_month = month == 12 ? 1 : month + 1
            next_year = month == 12 ? year + 1 : year
            timestamp(next_year, next_month, 1, 0, 0, 0) - 1
        'Quarterly' =>
            end_month = month + 2
            end_year = year
            if end_month > 12
                end_month := end_month - 12
                end_year := end_year + 1
            next_quarter_start = timestamp(end_year, end_month == 12 ? 1 : end_month + 1, 1, 0, 0, 0)
            if end_month == 12
                next_quarter_start := timestamp(end_year + 1, 1, 1, 0, 0, 0)
            next_quarter_start - 1
        'Monthly OPEX' =>
            get_next_opex_start(year, month) - 1
        'Quarterly OPEX' =>
            get_next_quarterly_opex_start(year, month) - 1
        => period_start

// ═══════════════════════════════════════════════════════════════════════════
// PERIODIC TPO PROCESSOR
// ═══════════════════════════════════════════════════════════════════════════

process_tpo_for_period(period_highs, period_lows, period_range_high, period_range_low, period_drawing_start, period_drawing_end, period_idx, is_current_period, period_open, period_close, ib_high, ib_low, boxes_ref, all_labels_ref, single_print_lines_ref, single_print_boxes_ref, oc_lines_ref) =>
    if period_range_high > period_range_low
        tick_size = (period_range_high - period_range_low) / tpo_levels
        counts = array.new<int>()

        for i = 0 to tpo_levels - 1 by 1
            array.push(counts, 0)

        for block = 0 to array.size(period_highs) - 1 by 1
            block_high_val = array.get(period_highs, block)
            block_low_val = array.get(period_lows, block)

            for level = 0 to tpo_levels - 1 by 1
                level_bottom = period_range_low + level * tick_size
                level_top = period_range_low + (level + 1) * tick_size

                if block_low_val <= level_top and block_high_val >= level_bottom
                    current_count = array.get(counts, level)
                    array.set(counts, level, current_count + 1)

        max_count = 0
        poc_level = 0
        for i = 0 to array.size(counts) - 1 by 1
            count = array.get(counts, i)
            if count > max_count
                max_count := count
                poc_level := i

        float vah = na
        float val = na
        if show_value_area and array.size(counts) > 1
            total_tpo = 0
            for i = 0 to array.size(counts) - 1 by 1
                total_tpo := total_tpo + array.get(counts, i)

            target_tpo = total_tpo * (value_area_pct / 100)

            vah_level = poc_level
            val_level = poc_level
            current_tpo = array.get(counts, poc_level)

            while current_tpo < target_tpo and (vah_level < array.size(counts) - 1 or val_level > 0)
                expand_up = false
                expand_down = false

                if vah_level < array.size(counts) - 1 and val_level > 0
                    up_tpo = array.get(counts, vah_level + 1)
                    down_tpo = array.get(counts, val_level - 1)
                    expand_up := up_tpo >= down_tpo
                    expand_down := not expand_up
                else if vah_level < array.size(counts) - 1
                    expand_up := true
                else if val_level > 0
                    expand_down := true

                if expand_up
                    vah_level := vah_level + 1
                    current_tpo := current_tpo + array.get(counts, vah_level)
                else if expand_down
                    val_level := val_level - 1
                    current_tpo := current_tpo + array.get(counts, val_level)

            vah := period_range_low + (vah_level + 1) * tick_size
            val := period_range_low + val_level * tick_size

        single_prints = array.new<float>()
        if show_single_prints
            for i = 0 to array.size(counts) - 1 by 1
                count = array.get(counts, i)
                if count == 1
                    level_bottom = period_range_low + i * tick_size
                    level_top = period_range_low + (i + 1) * tick_size
                    array.push(single_prints, level_bottom)
                    array.push(single_prints, level_top)

        if show_tpo_boxes and max_count > 0
            for i = 0 to array.size(counts) - 1 by 1
                count = array.get(counts, i)
                if count > 0
                    level_bottom = period_range_low + i * tick_size
                    level_top = period_range_low + (i + 1) * tick_size
                    width = math.round(count * 30 / max_count)
                    if width < 1
                        width := 1

                    box_color = color.new(tpo_color, 60 + period_idx * 5)
                    if show_value_area and not na(vah) and not na(val)
                        if level_bottom >= val and level_top <= vah
                            box_color := color.new(va_color, 50 + period_idx * 5)

                    box_obj = box.new(period_drawing_start, level_top, period_drawing_start + width, level_bottom, bgcolor = box_color, border_color = box_color)
                    array.push(boxes_ref, box_obj)

        line_end_position = is_current_period ? (levelOffsetRight <= 0 ? bar_index : bar_index + levelOffsetRight) : period_drawing_end

        if show_poc
            poc_price = period_range_low + poc_level * tick_size + tick_size / 2
            poc_line_period = line.new(period_drawing_start, poc_price, line_end_position, poc_price, color = poc_color, width = poc_line_width, style = getLineStyle(poc_line_style))

            if showLabels
                period_label_text = is_current_period ? 'POC (Current)' : 'POC (-' + str.tostring(period_idx) + ')'
                poc_label = label.new(line_end_position, poc_price, period_label_text, color = color.new(color.white, 100), textcolor = poc_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels_ref, poc_label)

        if show_value_area and not na(vah) and not na(val)
            va_box_period = box.new(period_drawing_start - 2, vah, period_drawing_start, val, border_color = va_color, bgcolor = color.new(va_color, 90), border_width = 2)

        if show_vah_val_lines and not na(vah) and not na(val)
            vah_line_period = line.new(period_drawing_start, vah, line_end_position, vah, color = vah_color, width = vah_line_width, style = getLineStyle(vah_line_style))
            val_line_period = line.new(period_drawing_start, val, line_end_position, val, color = val_color, width = val_line_width, style = getLineStyle(val_line_style))

            if showLabels
                vah_label_text = is_current_period ? 'VAH (Current)' : 'VAH (-' + str.tostring(period_idx) + ')'
                val_label_text = is_current_period ? 'VAL (Current)' : 'VAL (-' + str.tostring(period_idx) + ')'
                vah_label = label.new(line_end_position, vah, vah_label_text, color = color.new(color.white, 100), textcolor = vah_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                val_label = label.new(line_end_position, val, val_label_text, color = color.new(color.white, 100), textcolor = val_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels_ref, vah_label)
                array.push(all_labels_ref, val_label)

        if show_single_prints and array.size(single_prints) > 0
            for i = 0 to array.size(single_prints) - 1 by 2
                if i + 1 < array.size(single_prints)
                    sp_low = array.get(single_prints, i)
                    sp_high = array.get(single_prints, i + 1)

                    if single_print_style == 'Lines'
                        sp_high_line = line.new(period_drawing_start, sp_high, line_end_position, sp_high, color = single_print_color, width = 1, style = line.style_dashed)
                        sp_low_line = line.new(period_drawing_start, sp_low, line_end_position, sp_low, color = single_print_color, width = 1, style = line.style_dashed)
                        array.push(single_print_lines_ref, sp_high_line)
                        array.push(single_print_lines_ref, sp_low_line)
                    else
                        sp_box = box.new(period_drawing_start, sp_high, line_end_position, sp_low, border_color = single_print_color, bgcolor = color.new(single_print_color, 90), border_width = 1)
                        array.push(single_print_boxes_ref, sp_box)

        if show_open_close and not na(period_open) and not na(period_close)
            open_line = line.new(period_drawing_start, period_open, line_end_position, period_open, color = open_color, width = oc_line_width, style = getLineStyle(oc_line_style))
            close_line = line.new(period_drawing_start, period_close, line_end_position, period_close, color = close_color, width = oc_line_width, style = getLineStyle(oc_line_style))
            array.push(oc_lines_ref, open_line)
            array.push(oc_lines_ref, close_line)

            if showLabels
                open_label = label.new(line_end_position, period_open, 'Open', color = color.new(color.white, 100), textcolor = open_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                close_label = label.new(line_end_position, period_close, 'Close', color = color.new(color.white, 100), textcolor = close_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels_ref, open_label)
                array.push(all_labels_ref, close_label)

        if show_ib and not na(ib_high) and not na(ib_low)
            ib_vert_line = line.new(period_drawing_start, ib_high, period_drawing_start, ib_low, color = ib_color, width = 5, style = line.style_solid)
            ib_top_line = line.new(period_drawing_start, ib_high, line_end_position, ib_high, color = ib_color, width = ib_line_width, style = getLineStyle(ib_line_style))
            ib_bottom_line = line.new(period_drawing_start, ib_low, line_end_position, ib_low, color = ib_color, width = ib_line_width, style = getLineStyle(ib_line_style))

            array.push(oc_lines_ref, ib_vert_line)
            array.push(oc_lines_ref, ib_top_line)
            array.push(oc_lines_ref, ib_bottom_line)

            if showLabels
                ib_high_label = label.new(line_end_position, ib_high, 'IB High', color = color.new(color.white, 100), textcolor = ib_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                ib_low_label = label.new(line_end_position, ib_low, 'IB Low', color = color.new(color.white, 100), textcolor = ib_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels_ref, ib_high_label)
                array.push(all_labels_ref, ib_low_label)

// ═══════════════════════════════════════════════════════════════════════════
// MAIN STATE & DRAWING
// ═══════════════════════════════════════════════════════════════════════════

var boxes               = array.new<box>()
var line poc_line       = na
var box  va_box         = na
var line vah_line       = na
var line val_line       = na
var single_print_lines  = array.new<line>()
var single_print_boxes  = array.new<box>()
var oc_lines            = array.new<line>()
var array<label> all_labels = array.new<label>()

if barstate.islast
    // ─── Clear previous drawings ───────────────────────────────────────
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1 by 1
            box.delete(array.get(boxes, i))
        array.clear(boxes)

    if not na(poc_line)
        line.delete(poc_line)
    if not na(va_box)
        box.delete(va_box)
    if not na(vah_line)
        line.delete(vah_line)
    if not na(val_line)
        line.delete(val_line)
    if not na(vaz_vert_line)
        line.delete(vaz_vert_line)

    if array.size(single_print_lines) > 0
        for i = 0 to array.size(single_print_lines) - 1 by 1
            line.delete(array.get(single_print_lines, i))
        array.clear(single_print_lines)

    if array.size(single_print_boxes) > 0
        for i = 0 to array.size(single_print_boxes) - 1 by 1
            box.delete(array.get(single_print_boxes, i))
        array.clear(single_print_boxes)

    if array.size(oc_lines) > 0
        for i = 0 to array.size(oc_lines) - 1 by 1
            line.delete(array.get(oc_lines, i))
        array.clear(oc_lines)

    if array.size(all_labels) > 0
        for i = 0 to array.size(all_labels) - 1 by 1
            label.delete(array.get(all_labels, i))
        array.clear(all_labels)

    // Reset VAZ state
    vaz_vah := na
    vaz_val := na
    vaz_range_pct := na
    vaz_long_zone := false
    vaz_short_zone := false
    vaz_dead_zone := false

    // ─── Range determination ───────────────────────────────────────────
    blocks_high = array.new<float>()
    blocks_low  = array.new<float>()
    range_high  = 0.0
    range_low   = 999999.0

    var int drawing_start_bar = na

    if mode == 'Bars Back' or mode == 'Auto Lookback'
        max_lookback = math.min(effective_bars, 5000)
        drawing_start_bar := bar_index - max_lookback
        for i = 0 to max_lookback - 1 by 1
            float h = na
            float l = na
            if not na(block_high[i]) and not na(block_low[i])
                h := block_high[i]
                l := block_low[i]
            if not na(h) and not na(l)
                array.push(blocks_high, h)
                array.push(blocks_low, l)
                range_high := math.max(range_high, h)
                range_low := math.min(range_low, l)
                range_low

    else if mode == 'Fixed Range'
        drawing_start_bar := bar_index
        max_search = math.min(bar_index, 10000)
        for i = 0 to max_search by 1
            if bar_index - i < 0
                break
            if not na(time[i]) and time[i] <= start_time
                drawing_start_bar := bar_index - i
                break

        max_history = math.min(bar_index, 5000)
        for i = 0 to max_history by 1
            if bar_index - i < 0
                break
            bar_time = time[i]
            if not na(bar_time) and bar_time >= start_time and bar_time <= end_time
                float h = na
                float l = na
                if not na(block_high[i]) and not na(block_low[i])
                    h := block_high[i]
                    l := block_low[i]
                if not na(h) and not na(l)
                    array.push(blocks_high, h)
                    array.push(blocks_low, l)
                    range_high := math.max(range_high, h)
                    range_low := math.min(range_low, l)
                    range_low

    else if mode == 'Anchor'
        drawing_start_bar := bar_index
        max_search = math.min(bar_index, 10000)
        for i = 0 to max_search by 1
            if bar_index - i < 0
                break
            if not na(time[i]) and time[i] <= start_time
                drawing_start_bar := bar_index - i
                break

        max_history = math.min(bar_index, 5000)
        for i = 0 to max_history by 1
            if bar_index - i < 0
                break
            bar_time = time[i]
            if not na(bar_time) and bar_time >= start_time
                float h = na
                float l = na
                if not na(block_high[i]) and not na(block_low[i])
                    h := block_high[i]
                    l := block_low[i]
                if not na(h) and not na(l)
                    array.push(blocks_high, h)
                    array.push(blocks_low, l)
                    range_high := math.max(range_high, h)
                    range_low := math.min(range_low, l)
                    range_low

    else if mode == 'Visible Region'
        left_visible_time = chart.left_visible_bar_time
        right_visible_time = chart.right_visible_bar_time

        drawing_start_bar := bar_index
        max_search = math.min(bar_index, 10000)
        for i = 0 to max_search by 1
            if bar_index - i < 0
                break
            if not na(time[i]) and time[i] <= left_visible_time
                drawing_start_bar := bar_index - i
                break

        max_history = math.min(bar_index, 5000)
        for i = 0 to max_history by 1
            if bar_index - i < 0
                break
            bar_time = time[i]
            if not na(bar_time) and bar_time >= left_visible_time and bar_time <= right_visible_time
                float h = na
                float l = na
                if not na(block_high[i]) and not na(block_low[i])
                    h := block_high[i]
                    l := block_low[i]
                if not na(h) and not na(l)
                    array.push(blocks_high, h)
                    array.push(blocks_low, l)
                    range_high := math.max(range_high, h)
                    range_low := math.min(range_low, l)
                    range_low

    else if mode == 'Periodic'
        current_time = time

        if show_current_period
            current_period_blocks_high = array.new<float>()
            current_period_blocks_low = array.new<float>()

            current_period_start_time = get_period_start(period_type, current_time)

            current_period_drawing_start = bar_index
            max_search = math.min(bar_index, 5000)
            for i = 0 to max_search by 1
                if bar_index - i < 0
                    break
                if not na(time[i]) and time[i] <= current_period_start_time
                    current_period_drawing_start := bar_index - i
                    break

            max_history = math.min(bar_index, 2000)
            for i = 0 to max_history by 1
                if bar_index - i < 0
                    break
                bar_time = time[i]
                if not na(bar_time) and bar_time >= current_period_start_time and bar_time <= current_time
                    float h = na
                    float l = na
                    if not na(block_high[i]) and not na(block_low[i])
                        h := block_high[i]
                        l := block_low[i]
                    if not na(h) and not na(l)
                        array.push(current_period_blocks_high, h)
                        array.push(current_period_blocks_low, l)

            if array.size(current_period_blocks_high) > 0
                current_period_range_high = 0.0
                current_period_range_low = 999999.0

                for i = 0 to array.size(current_period_blocks_high) - 1
                    h = array.get(current_period_blocks_high, i)
                    l = array.get(current_period_blocks_low, i)
                    current_period_range_high := math.max(current_period_range_high, h)
                    current_period_range_low := math.min(current_period_range_low, l)

                float period_open_price = na
                float period_close_price = close

                bars_to_look_back = bar_index - current_period_drawing_start
                if bars_to_look_back >= 0
                    period_open_price := open[bars_to_look_back]

                float period_ib_high = na
                float period_ib_low = na

                if show_ib
                    block_minutes = timeframe.in_seconds(block_time) / 60
                    ib_duration_mins = block_minutes * ib_block_count
                    ib_end_time = current_period_start_time + ib_duration_mins * 60000

                    period_ib_high := 0.0
                    period_ib_low := 999999.0

                    check_to_time = math.min(current_time, ib_end_time)

                    for i = 0 to max_history
                        if bar_index - i < 0
                            break
                        b_time = time[i]
                        if not na(b_time) and b_time >= current_period_start_time and b_time <= check_to_time
                            if not na(high[i]) and not na(low[i])
                                period_ib_high := math.max(period_ib_high, high[i])
                                period_ib_low := math.min(period_ib_low, low[i])

                    if period_ib_high == 0.0
                        period_ib_high := na
                        period_ib_low := na

                process_tpo_for_period(current_period_blocks_high, current_period_blocks_low, current_period_range_high, current_period_range_low, current_period_drawing_start, bar_index, 0, true, period_open_price, period_close_price, period_ib_high, period_ib_low, boxes, all_labels, single_print_lines, single_print_boxes, oc_lines)

        for p = 0 to periods_count - 1 by 1
            period_blocks_high = array.new<float>()
            period_blocks_low = array.new<float>()

            temp_time = current_time
            for i = 1 to p + 1 by 1
                if period_type == 'Daily'
                    temp_time := temp_time - 86400000
                else if period_type == 'Weekly'
                    temp_time := temp_time - 604800000
                else if period_type == 'Monthly'
                    temp_time := temp_time - 2629746000
                else if period_type == 'Quarterly'
                    temp_time := temp_time - 7889238000
                else if period_type == 'Monthly OPEX'
                    temp_year = year(temp_time)
                    temp_month = month(temp_time)
                    temp_month := temp_month - 1
                    if temp_month < 1
                        temp_month := 12
                        temp_year := temp_year - 1
                    temp_time := get_third_friday(temp_year, temp_month)
                else if period_type == 'Quarterly OPEX'
                    temp_year = year(temp_time)
                    temp_month = month(temp_time)
                    [prev_year, prev_month] = get_previous_quarterly_opex_month(temp_year, temp_month)
                    temp_time := get_third_friday(prev_year, prev_month)

            period_start_time = get_period_start(period_type, temp_time)
            period_end_time = get_period_end(period_type, period_start_time)

            period_drawing_start = bar_index
            period_drawing_end = bar_index

            max_search = math.min(bar_index, 5000)

            for i = 0 to max_search by 1
                if bar_index - i < 0
                    break
                if not na(time[i]) and time[i] <= period_start_time
                    period_drawing_start := bar_index - i
                    break

            for i = 0 to max_search by 1
                if bar_index - i < 0
                    break
                if not na(time[i]) and time[i] <= period_end_time
                    period_drawing_end := bar_index - i
                    break

            max_history = math.min(bar_index, 2000)

            for i = 0 to max_history by 1
                if bar_index - i < 0
                    break
                bar_time = time[i]
                if not na(bar_time) and bar_time >= period_start_time and bar_time <= period_end_time
                    float h = na
                    float l = na
                    if not na(block_high[i]) and not na(block_low[i])
                        h := block_high[i]
                        l := block_low[i]
                    if not na(h) and not na(l)
                        array.push(period_blocks_high, h)
                        array.push(period_blocks_low, l)

            if array.size(period_blocks_high) > 0
                period_range_high = 0.0
                period_range_low = 999999.0

                for i = 0 to array.size(period_blocks_high) - 1
                    h = array.get(period_blocks_high, i)
                    l = array.get(period_blocks_low, i)
                    period_range_high := math.max(period_range_high, h)
                    period_range_low := math.min(period_range_low, l)

                float period_open_price = na
                float period_close_price = na

                bars_to_look_back_start = bar_index - period_drawing_start
                if bars_to_look_back_start >= 0
                    period_open_price := open[bars_to_look_back_start]

                bars_to_look_back_end = bar_index - period_drawing_end
                if bars_to_look_back_end >= 0
                    period_close_price := close[bars_to_look_back_end]

                float period_ib_high = na
                float period_ib_low = na

                if show_ib
                    block_minutes = timeframe.in_seconds(block_time) / 60
                    ib_duration_mins = block_minutes * ib_block_count
                    ib_end_time = period_start_time + ib_duration_mins * 60000

                    period_ib_high := 0.0
                    period_ib_low := 999999.0

                    for i = 0 to max_history
                        if bar_index - i < 0
                            break
                        b_time = time[i]
                        if not na(b_time) and b_time >= period_start_time and b_time <= ib_end_time
                            if not na(high[i]) and not na(low[i])
                                period_ib_high := math.max(period_ib_high, high[i])
                                period_ib_low := math.min(period_ib_low, low[i])

                    if period_ib_high == 0.0
                        period_ib_high := na
                        period_ib_low := na

                process_tpo_for_period(period_blocks_high, period_blocks_low, period_range_high, period_range_low, period_drawing_start, period_drawing_end, p + 1, false, period_open_price, period_close_price, period_ib_high, period_ib_low, boxes, all_labels, single_print_lines, single_print_boxes, oc_lines)

    // ─── Single-window profile (non-Periodic) ─────────────────────────
    if range_high > range_low and array.size(blocks_high) > 0 and mode != 'Periodic'
        tick_size = (range_high - range_low) / tpo_levels
        counts = array.new<int>()

        for i = 0 to tpo_levels - 1 by 1
            array.push(counts, 0)

        for block = 0 to array.size(blocks_high) - 1 by 1
            block_high_val = array.get(blocks_high, block)
            block_low_val = array.get(blocks_low, block)

            for level = 0 to tpo_levels - 1 by 1
                level_bottom = range_low + level * tick_size
                level_top = range_low + (level + 1) * tick_size

                if block_low_val <= level_top and block_high_val >= level_bottom
                    current_count = array.get(counts, level)
                    array.set(counts, level, current_count + 1)

        max_count = 0
        poc_level = 0
        for i = 0 to array.size(counts) - 1 by 1
            count = array.get(counts, i)
            if count > max_count
                max_count := count
                poc_level := i
                poc_level

        float vah = na
        float val = na
        if array.size(counts) > 1
            total_tpo = 0
            for i = 0 to array.size(counts) - 1 by 1
                total_tpo := total_tpo + array.get(counts, i)
                total_tpo

            target_tpo = total_tpo * (value_area_pct / 100)

            vah_level = poc_level
            val_level = poc_level
            current_tpo = array.get(counts, poc_level)

            while current_tpo < target_tpo and (vah_level < array.size(counts) - 1 or val_level > 0)
                expand_up = false
                expand_down = false

                if vah_level < array.size(counts) - 1 and val_level > 0
                    up_tpo = array.get(counts, vah_level + 1)
                    down_tpo = array.get(counts, val_level - 1)
                    expand_up := up_tpo >= down_tpo
                    expand_down := not expand_up
                    expand_down
                else if vah_level < array.size(counts) - 1
                    expand_up := true
                    expand_up
                else if val_level > 0
                    expand_down := true
                    expand_down

                if expand_up
                    vah_level := vah_level + 1
                    current_tpo := current_tpo + array.get(counts, vah_level)
                    current_tpo
                else if expand_down
                    val_level := val_level - 1
                    current_tpo := current_tpo + array.get(counts, val_level)
                    current_tpo

            vah := range_low + (vah_level + 1) * tick_size
            val := range_low + val_level * tick_size
            val

        // ─── Capture VAH/VAL for VAZ ──────────────────────────────────
        if not na(vah) and not na(val)
            vaz_vah := vah
            vaz_val := val

        single_prints = array.new<float>()
        if show_single_prints
            for i = 0 to array.size(counts) - 1 by 1
                count = array.get(counts, i)
                if count == 1
                    level_bottom = range_low + i * tick_size
                    level_top = range_low + (i + 1) * tick_size
                    array.push(single_prints, level_bottom)
                    array.push(single_prints, level_top)

        if show_tpo_boxes and max_count > 0
            for i = 0 to array.size(counts) - 1 by 1
                count = array.get(counts, i)
                if count > 0
                    level_bottom = range_low + i * tick_size
                    level_top = range_low + (i + 1) * tick_size
                    width = math.round(count * 30 / max_count)
                    if width < 1
                        width := 1
                        width

                    box_color = tpo_color
                    if show_value_area and not na(vah) and not na(val)
                        if level_bottom >= val and level_top <= vah
                            box_color := color.new(va_color, 50)
                            box_color

                    box_obj = box.new(drawing_start_bar, level_top, drawing_start_bar + width, level_bottom, bgcolor = box_color, border_color = box_color)
                    array.push(boxes, box_obj)

        if show_poc
            poc_price = range_low + poc_level * tick_size + tick_size / 2
            line_end = levelOffsetRight <= 0 ? bar_index : bar_index + levelOffsetRight
            line_extend = levelOffsetRight <= 0 ? extend.right : extend.none
            poc_line := line.new(drawing_start_bar, poc_price, line_end, poc_price, color = poc_color, width = poc_line_width, extend = line_extend, style = getLineStyle(poc_line_style))
            if showLabels
                poc_label = label.new(bar_index + levelOffsetRight, poc_price, 'POC', color = color.new(color.white, 100), textcolor = poc_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels, poc_label)

        if show_value_area and not na(vah) and not na(val)
            va_box := box.new(drawing_start_bar - 2, vah, drawing_start_bar, val, border_color = va_color, bgcolor = color.new(va_color, 90), border_width = 2)
            va_box

        if show_vah_val_lines and not na(vah) and not na(val)
            line_end = levelOffsetRight <= 0 ? bar_index : bar_index + levelOffsetRight
            line_extend = levelOffsetRight <= 0 ? extend.right : extend.none
            vah_line := line.new(drawing_start_bar, vah, line_end, vah, color = vah_color, width = vah_line_width, extend = line_extend, style = getLineStyle(vah_line_style))
            val_line := line.new(drawing_start_bar, val, line_end, val, color = val_color, width = val_line_width, extend = line_extend, style = getLineStyle(val_line_style))
            if showLabels
                vah_label = label.new(bar_index + levelOffsetRight, vah, 'VAH', color = color.new(color.white, 100), textcolor = vah_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                val_label = label.new(bar_index + levelOffsetRight, val, 'VAL', color = color.new(color.white, 100), textcolor = val_color, style = getLabelStyle(), size = getFontSize(), text_font_family = font.family_monospace)
                array.push(all_labels, vah_label)
                array.push(all_labels, val_label)

        if show_single_prints and array.size(single_prints) > 0
            for i = 0 to array.size(single_prints) - 1 by 2
                if i + 1 < array.size(single_prints)
                    sp_low = array.get(single_prints, i)
                    sp_high = array.get(single_prints, i + 1)

                    if single_print_style == 'Lines'
                        sp_high_line = line.new(drawing_start_bar, sp_high, bar_index + 5, sp_high, color = single_print_color, width = 1, extend = extend.right, style = line.style_dashed)
                        sp_low_line = line.new(drawing_start_bar, sp_low, bar_index + 5, sp_low, color = single_print_color, width = 1, extend = extend.right, style = line.style_dashed)
                        array.push(single_print_lines, sp_high_line)
                        array.push(single_print_lines, sp_low_line)
                    else
                        sp_box = box.new(drawing_start_bar, sp_high, bar_index + 5, sp_low, border_color = single_print_color, bgcolor = color.new(single_print_color, 90), border_width = 1)
                        array.push(single_print_boxes, sp_box)

    // ═══════════════════════════════════════════════════════════════════════
    // VAZ COMPUTATION
    // ═══════════════════════════════════════════════════════════════════════
    if vaz_enable and not na(vaz_vah) and not na(vaz_val) and vaz_vah > vaz_val
        range_size = vaz_vah - vaz_val
        vaz_range_pct := (close - vaz_val) / range_size * 100
        // Out-of-range (above VAH or below VAL) = dead zone
        out_of_range = vaz_range_pct < 0 or vaz_range_pct > 100
        vaz_long_zone  := not out_of_range and vaz_range_pct <= vaz_long_max_pct
        vaz_short_zone := not out_of_range and vaz_range_pct >= vaz_short_min_pct
        vaz_dead_zone  := not vaz_long_zone and not vaz_short_zone

        // Draw full-height vertical line at current bar, colored by zone
        if vaz_show_vline
            zone_col = vaz_long_zone ? vaz_long_color : vaz_short_zone ? vaz_short_color : vaz_dead_color
            vaz_vert_line := line.new(bar_index, vaz_vah, bar_index, vaz_val, color = zone_col, width = vaz_vline_width, style = getLineStyle(vaz_vline_style), extend = extend.both)

// ═══════════════════════════════════════════════════════════════════════════
// ZONE BACKGROUND HIGHLIGHT
// ═══════════════════════════════════════════════════════════════════════════
bgcolor(vaz_enable and vaz_show_bg and barstate.islast and vaz_long_zone  ? color.new(vaz_long_color, 85)  : na, title = 'VAZ Long Zone')
bgcolor(vaz_enable and vaz_show_bg and barstate.islast and vaz_short_zone ? color.new(vaz_short_color, 85) : na, title = 'VAZ Short Zone')
bgcolor(vaz_enable and vaz_show_bg and barstate.islast and vaz_dead_zone  ? color.new(vaz_dead_color, 90)  : na, title = 'VAZ Dead Zone')

// ═══════════════════════════════════════════════════════════════════════════
// BAR COLORING BY ZONE
// ═══════════════════════════════════════════════════════════════════════════
bar_zone_color = vaz_enable and vaz_color_bars and not na(vaz_range_pct) ? (vaz_long_zone ? vaz_long_color : vaz_short_zone ? vaz_short_color : vaz_dead_color) : na
barcolor(bar_zone_color, title = 'VAZ Bar Color')

// ═══════════════════════════════════════════════════════════════════════════
// INFO BOX (Table) — drawn AFTER VAZ so we can color by zone
// ═══════════════════════════════════════════════════════════════════════════

// Determine info box background based on VAZ state
infobox_bg_final = info_box_bg
if vaz_enable and vaz_color_infobox and not na(vaz_range_pct)
    if vaz_long_zone
        infobox_bg_final := color.new(vaz_long_color, 30)
    else if vaz_short_zone
        infobox_bg_final := color.new(vaz_short_color, 30)
    else
        infobox_bg_final := color.new(vaz_dead_color, 30)

var table info_box = table.new(getInfoBoxPosition(), 2, 7, bgcolor = info_box_bg, border_color = info_box_border ? color.gray : color.new(color.gray, 100), border_width = info_box_border ? 1 : 0, frame_color = info_box_border ? color.gray : color.new(color.gray, 100), frame_width = info_box_border ? 1 : 0)

if barstate.islast and show_info_box
    table.clear(info_box, 0, 0, 1, 6)

    font_fam = info_box_mono ? font.family_monospace : font.family_default

    // VAZ label string
    vaz_label_text = ''
    if vaz_enable and not na(vaz_range_pct)
        out_of_range = vaz_range_pct < 0 or vaz_range_pct > 100
        if not out_of_range
            zone_str = vaz_long_zone ? 'LONG' : vaz_short_zone ? 'SHORT' : 'DEAD'
            vaz_label_text := zone_str + ' ' + str.tostring(math.round(vaz_range_pct, 1)) + '%'

    if info_box_compact
        header_text = mode == 'Auto Lookback' ? 'VA·AUTO' : 'VA·' + mode
        table.cell(info_box, 0, 0, header_text, text_color = color.white, bgcolor = color.new(color.blue, 60), text_size = getInfoBoxSize(), text_font_family = font_fam)

        if mode == 'Auto Lookback'
            tf_color = auto_fallback ? color.orange : color.white
            table.cell(info_box, 0, 1, 'TF: '  + auto_tf_label,                text_color = tf_color,    text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 2, 'P: '   + auto_period_label,            text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 3, 'B: '   + str.tostring(effective_bars), text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
        else if mode == 'Bars Back'
            table.cell(info_box, 0, 1, 'TF: '  + str.tostring(timeframe.period), text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 2, 'B: '   + str.tostring(effective_bars),   text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 3, '',                                       text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
        else
            table.cell(info_box, 0, 1, 'TF: '  + str.tostring(timeframe.period), text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 2, '', text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 3, '', text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)

        table.cell(info_box, 0, 4, 'Blk: ' + block_time, text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)

        if vaz_enable and vaz_label_text != ''
            vaz_text_color = vaz_long_zone ? color.lime : vaz_short_zone ? color.red : color.silver
            table.cell(info_box, 0, 5, vaz_label_text, text_color = vaz_text_color, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
    else
        header_text = mode == 'Auto Lookback' ? '⚙ VA LOOKBACK (AUTO)' : '⚙ VA LOOKBACK'
        table.cell(info_box, 0, 0, header_text, text_color = color.white, bgcolor = color.new(color.blue, 50), text_size = getInfoBoxSize(), text_font_family = font_fam)
        table.merge_cells(info_box, 0, 0, 1, 0)

        table.cell(info_box, 0, 1, 'Mode',  text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
        table.cell(info_box, 1, 1, mode,    text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)

        if mode == 'Auto Lookback'
            tf_color = auto_fallback ? color.orange : color.white
            table.cell(info_box, 0, 2, 'TF',           text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 2, auto_tf_label,  text_color = tf_color,   text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)

            table.cell(info_box, 0, 3, 'Period',          text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 3, auto_period_label, text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)

            table.cell(info_box, 0, 4, 'Bars',                       text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 4, str.tostring(effective_bars), text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
        else if mode == 'Bars Back'
            table.cell(info_box, 0, 2, 'TF',                         text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 2, str.tostring(timeframe.period),text_color = color.white,text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 3, 'Bars',                       text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 3, str.tostring(effective_bars), text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 4, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 4, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
        else
            table.cell(info_box, 0, 2, 'TF',                          text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 2, str.tostring(timeframe.period),text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 3, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 3, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 0, 4, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_left, text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 4, '', text_color = color.gray, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)

        table.cell(info_box, 0, 5, 'Block',     text_color = color.gray,  text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
        table.cell(info_box, 1, 5, block_time,  text_color = color.white, text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)

        if vaz_enable and vaz_label_text != ''
            vaz_text_color = vaz_long_zone ? color.lime : vaz_short_zone ? color.red : color.silver
            table.cell(info_box, 0, 6, 'VAZ',           text_color = color.gray,    text_size = getInfoBoxSize(), text_halign = text.align_left,  text_font_family = font_fam, bgcolor = infobox_bg_final)
            table.cell(info_box, 1, 6, vaz_label_text,  text_color = vaz_text_color,text_size = getInfoBoxSize(), text_halign = text.align_right, text_font_family = font_fam, bgcolor = infobox_bg_final)
````
