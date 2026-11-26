# HTF Levels + ORB + VWAP + Volume Panel + HTF EMAs + Pre-Market

- url: https://www.tradingview.com/script/GwUUpPCo-HTF-Levels-ORB-VWAP-Volume-Panel-HTF-EMAs-Pre-Market/
- type: indicator
- pine_id: PUB;c654748863f943048707dc909c373b38
- version: 1.0

## Description

The best of the best. Whoever finds this - ENJOY - because you deserve it!

## Source Code

````pine
//@version=6
indicator("HTF Levels + ORB + VWAP + Volume Panel + HTF EMAs + Pre-Market", overlay=true)

// ============================================================================
// SETTINGS
// ============================================================================
show_4h = input.bool(true, "Show 4-Hour Levels")
show_daily = input.bool(true, "Show Daily Levels")
show_weekly = input.bool(true, "Show Weekly Levels")
show_monthly = input.bool(true, "Show Monthly Levels")
show_12m = input.bool(true, "Show 12-Month Levels (Current Year)")
show_orb = input.bool(true, "Show 9:45 ORB (15min Opening Range)")
show_vwap = input.bool(true, "Show VWAP (Smooth)")
show_volume_panel = input.bool(true, "Show Volume Trend Panel")

// Pre-Market Settings
show_premarket = input.bool(true, "Show Pre-Market High/Low")
premarket_start = input.int(0400, "Pre-Market Start (ET)", minval=0, maxval=2359, step=100)
premarket_end = input.int(0930, "Pre-Market End (ET)", minval=0, maxval=2359, step=100)

// ============================================================================
// HIGHER TIMEFRAME EMA SETTINGS
// ============================================================================
show_ema_20 = input.bool(true, "Show Monthly EMA 20")
show_ema_50 = input.bool(true, "Show Weekly EMA 50")
show_ema_200 = input.bool(true, "Show Daily EMA 200")

// ============================================================================
// HIGHER TIMEFRAME EMAS (Daily, Weekly, Monthly only)
// ============================================================================
daily_ema_200 = request.security(syminfo.tickerid, "D", ta.ema(close, 200), lookahead=barmerge.lookahead_off)
weekly_ema_50 = request.security(syminfo.tickerid, "W", ta.ema(close, 50), lookahead=barmerge.lookahead_off)
monthly_ema_20 = request.security(syminfo.tickerid, "M", ta.ema(close, 20), lookahead=barmerge.lookahead_off)

plot(show_ema_200 ? daily_ema_200 : na, "Daily EMA 200", color.new(color.red, 30), linewidth=1)
plot(show_ema_50 ? weekly_ema_50 : na, "Weekly EMA 50", color.new(color.orange, 30), linewidth=1)
plot(show_ema_20 ? monthly_ema_20 : na, "Monthly EMA 20", color.new(color.yellow, 30), linewidth=1)

// ============================================================================
// VWAP - SMOOTH & NON-NOISY
// ============================================================================
vwap_value = ta.vwap(hlc3)
vwap_color = show_vwap ? color.new(color.white, 20) : na
plot(show_vwap ? vwap_value : na, "VWAP", vwap_color, style=plot.style_line, linewidth=2)

// ============================================================================
// HELPER: DETECT NEW PERIOD USING TIMESTAMP
// ============================================================================
new_period(period) =>
    current = request.security(syminfo.tickerid, period, time, lookahead=barmerge.lookahead_off)
    not na(current) and (na(current[1]) or current != current[1])

// ============================================================================
// VOLUME TREND HELPER FUNCTION
// ============================================================================
get_volume_trend(tf) =>
    vol = request.security(syminfo.tickerid, tf, volume, lookahead=barmerge.lookahead_off)
    avg_vol = request.security(syminfo.tickerid, tf, ta.sma(volume, 20), lookahead=barmerge.lookahead_off)
    ratio = vol / avg_vol
    if na(ratio) or ratio <= 0.7
        "LOW"
    else if ratio >= 1.5
        "HIGH"
    else
        "CHOP"

// ============================================================================
// PRE-MARKET HIGH/LOW (4:00 AM - 9:30 AM ET)
// ============================================================================
var float premarket_high = na
var float premarket_low = na
var line premarket_high_line = na
var line premarket_low_line = na
var label premarket_high_label = na
var label premarket_low_label = na

current_time = time(timeframe.period)
current_hour_min = hour(current_time) * 100 + minute(current_time)
is_premarket = (current_hour_min >= premarket_start and current_hour_min < premarket_end)

if show_premarket and not na(current_time)
    if is_premarket and not is_premarket[1]
        premarket_high := high
        premarket_low := low
    else if is_premarket
        premarket_high := math.max(premarket_high, high)
        premarket_low := math.min(premarket_low, low)
    else if not is_premarket and is_premarket[1] and not na(premarket_high) and not na(premarket_low)
        line.delete(premarket_high_line)
        line.delete(premarket_low_line)
        label.delete(premarket_high_label)
        label.delete(premarket_low_label)
        
        premarket_high_line := line.new(bar_index, premarket_high, bar_index + 50, premarket_high, 
                                        extend=extend.right, color=color.new(color.aqua, 0), 
                                        style=line.style_dashed, width=2)
        premarket_high_label := label.new(bar_index + 25, premarket_high, "PM H", 
                                          color=color.new(color.aqua, 80), 
                                          textcolor=color.new(color.aqua, 0),
                                          style=label.style_label_center, 
                                          size=size.small)
        
        premarket_low_line := line.new(bar_index, premarket_low, bar_index + 50, premarket_low, 
                                       extend=extend.right, color=color.new(color.aqua, 0), 
                                       style=line.style_dashed, width=2)
        premarket_low_label := label.new(bar_index + 25, premarket_low, "PM L", 
                                         color=color.new(color.aqua, 80), 
                                         textcolor=color.new(color.aqua, 0),
                                         style=label.style_label_center, 
                                         size=size.small)

// ============================================================================
// 9:45 AM ORB (15-MINUTE OPENING RANGE)
// ============================================================================
var float orb_high = na
var float orb_low = na
var line orb_high_line = na
var line orb_low_line = na
var label orb_high_label = na
var label orb_low_label = na

current_15min_time = request.security(syminfo.tickerid, "15", time, lookahead=barmerge.lookahead_off)
current_hour = hour(current_15min_time)
current_minute = minute(current_15min_time)
is_945_candle = (current_hour == 9 and current_minute == 45)

if is_945_candle and not is_945_candle[1] and show_orb
    line.delete(orb_high_line)
    line.delete(orb_low_line)
    label.delete(orb_high_label)
    label.delete(orb_low_label)
    
    orb_high := request.security(syminfo.tickerid, "15", high[1], lookahead=barmerge.lookahead_off)
    orb_low := request.security(syminfo.tickerid, "15", low[1], lookahead=barmerge.lookahead_off)
    
    if not na(orb_high)
        orb_high_line := line.new(bar_index, orb_high, bar_index + 50, orb_high, 
                                  extend=extend.right, color=color.new(color.white, 0), 
                                  style=line.style_dashed, width=2)
        orb_high_label := label.new(bar_index + 25, orb_high, "ORB", 
                                    color=color.new(color.white, 80), 
                                    textcolor=color.new(color.white, 0),
                                    style=label.style_label_center, 
                                    size=size.small)
    
    if not na(orb_low)
        orb_low_line := line.new(bar_index, orb_low, bar_index + 50, orb_low, 
                                 extend=extend.right, color=color.new(color.white, 0), 
                                 style=line.style_dashed, width=2)
        orb_low_label := label.new(bar_index + 25, orb_low, "ORB", 
                                   color=color.new(color.white, 80), 
                                   textcolor=color.new(color.white, 0),
                                   style=label.style_label_center, 
                                   size=size.small)

// ============================================================================
// 4-HOUR LEVELS (GOLD) - LABEL: "4"
// ============================================================================
var float h4_high = na
var float h4_low = na
var line h4_high_line = na
var line h4_low_line = na
var label h4_high_label = na
var label h4_low_label = na

if new_period("240")
    line.delete(h4_high_line)
    line.delete(h4_low_line)
    label.delete(h4_high_label)
    label.delete(h4_low_label)
    
    [prev_h4_high, prev_h4_low] = request.security(syminfo.tickerid, "240", [high[1], low[1]], lookahead=barmerge.lookahead_off)
    
    h4_high := prev_h4_high
    h4_low := prev_h4_low
    
    if show_4h and not na(h4_high)
        h4_high_line := line.new(bar_index, h4_high, bar_index + 50, h4_high, 
                                 extend=extend.right, color=color.new(color.yellow, 0), 
                                 style=line.style_dashed, width=1)
        h4_high_label := label.new(bar_index + 25, h4_high, "4", 
                                   color=color.new(color.yellow, 80), 
                                   textcolor=color.new(color.yellow, 0),
                                   style=label.style_label_center, 
                                   size=size.small)
    
    if show_4h and not na(h4_low)
        h4_low_line := line.new(bar_index, h4_low, bar_index + 50, h4_low, 
                                extend=extend.right, color=color.new(color.yellow, 0), 
                                style=line.style_dashed, width=1)
        h4_low_label := label.new(bar_index + 25, h4_low, "4", 
                                  color=color.new(color.yellow, 80), 
                                  textcolor=color.new(color.yellow, 0),
                                  style=label.style_label_center, 
                                  size=size.small)

// ============================================================================
// DAILY LEVELS (RED) - LABEL: "D"
// ============================================================================
var float daily_high = na
var float daily_low = na
var line daily_high_line = na
var line daily_low_line = na
var label daily_high_label = na
var label daily_low_label = na

if new_period("D")
    line.delete(daily_high_line)
    line.delete(daily_low_line)
    label.delete(daily_high_label)
    label.delete(daily_low_label)
    
    [prev_day_high, prev_day_low] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)
    
    daily_high := prev_day_high
    daily_low := prev_day_low
    
    if show_daily and not na(daily_high)
        daily_high_line := line.new(bar_index, daily_high, bar_index + 50, daily_high, 
                                    extend=extend.right, color=color.new(color.red, 0), 
                                    style=line.style_dashed, width=1)
        daily_high_label := label.new(bar_index + 25, daily_high, "D", 
                                      color=color.new(color.red, 80), 
                                      textcolor=color.new(color.red, 0),
                                      style=label.style_label_center, 
                                      size=size.small)
    
    if show_daily and not na(daily_low)
        daily_low_line := line.new(bar_index, daily_low, bar_index + 50, daily_low, 
                                   extend=extend.right, color=color.new(color.red, 0), 
                                   style=line.style_dashed, width=1)
        daily_low_label := label.new(bar_index + 25, daily_low, "D", 
                                     color=color.new(color.red, 80), 
                                     textcolor=color.new(color.red, 0),
                                     style=label.style_label_center, 
                                     size=size.small)

// ============================================================================
// WEEKLY LEVELS (PURPLE) - LABEL: "W"
// ============================================================================
var float weekly_high = na
var float weekly_low = na
var line weekly_high_line = na
var line weekly_low_line = na
var label weekly_high_label = na
var label weekly_low_label = na

if new_period("W")
    line.delete(weekly_high_line)
    line.delete(weekly_low_line)
    label.delete(weekly_high_label)
    label.delete(weekly_low_label)
    
    [prev_week_high, prev_week_low] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_off)
    
    weekly_high := prev_week_high
    weekly_low := prev_week_low
    
    if show_weekly and not na(weekly_high)
        weekly_high_line := line.new(bar_index, weekly_high, bar_index + 50, weekly_high, 
                                     extend=extend.right, color=color.new(color.purple, 0), 
                                     style=line.style_dashed, width=2)
        weekly_high_label := label.new(bar_index + 25, weekly_high, "W", 
                                       color=color.new(color.purple, 80), 
                                       textcolor=color.new(color.purple, 0),
                                       style=label.style_label_center, 
                                       size=size.small)
    
    if show_weekly and not na(weekly_low)
        weekly_low_line := line.new(bar_index, weekly_low, bar_index + 50, weekly_low, 
                                    extend=extend.right, color=color.new(color.purple, 0), 
                                    style=line.style_dashed, width=2)
        weekly_low_label := label.new(bar_index + 25, weekly_low, "W", 
                                      color=color.new(color.purple, 80), 
                                      textcolor=color.new(color.purple, 0),
                                      style=label.style_label_center, 
                                      size=size.small)

// ============================================================================
// MONTHLY LEVELS (ORANGE) - LABEL: "M"
// ============================================================================
var float monthly_high = na
var float monthly_low = na
var line monthly_high_line = na
var line monthly_low_line = na
var label monthly_high_label = na
var label monthly_low_label = na

if new_period("M")
    line.delete(monthly_high_line)
    line.delete(monthly_low_line)
    label.delete(monthly_high_label)
    label.delete(monthly_low_label)
    
    [prev_month_high, prev_month_low] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_off)
    
    monthly_high := prev_month_high
    monthly_low := prev_month_low
    
    if show_monthly and not na(monthly_high)
        monthly_high_line := line.new(bar_index, monthly_high, bar_index + 50, monthly_high, 
                                      extend=extend.right, color=color.new(color.orange, 0), 
                                      style=line.style_dashed, width=2)
        monthly_high_label := label.new(bar_index + 25, monthly_high, "M", 
                                        color=color.new(color.orange, 80), 
                                        textcolor=color.new(color.orange, 0),
                                        style=label.style_label_center, 
                                        size=size.small)
    
    if show_monthly and not na(monthly_low)
        monthly_low_line := line.new(bar_index, monthly_low, bar_index + 50, monthly_low, 
                                     extend=extend.right, color=color.new(color.orange, 0), 
                                     style=line.style_dashed, width=2)
        monthly_low_label := label.new(bar_index + 25, monthly_low, "M", 
                                       color=color.new(color.orange, 80), 
                                       textcolor=color.new(color.orange, 0),
                                       style=label.style_label_center, 
                                       size=size.small)

// ============================================================================
// 12-MONTH LEVELS (AQUA) - LABEL: "12M"
// ============================================================================
var float year_high = na
var float year_low = na
var line year_high_line = na
var line year_low_line = na
var label year_high_label = na
var label year_low_label = na

if new_period("12M")
    line.delete(year_high_line)
    line.delete(year_low_line)
    label.delete(year_high_label)
    label.delete(year_low_label)
    
    [prev_year_high, prev_year_low] = request.security(syminfo.tickerid, "12M", [high[1], low[1]], lookahead=barmerge.lookahead_off)
    
    year_high := prev_year_high
    year_low := prev_year_low
    
    if show_12m and not na(year_high)
        year_high_line := line.new(bar_index, year_high, bar_index + 50, year_high, 
                                   extend=extend.right, color=color.new(color.aqua, 0), 
                                   style=line.style_dashed, width=3)
        year_high_label := label.new(bar_index + 25, year_high, "12M", 
                                     color=color.new(color.aqua, 80), 
                                     textcolor=color.new(color.aqua, 0),
                                     style=label.style_label_center, 
                                     size=size.small)
    
    if show_12m and not na(year_low)
        year_low_line := line.new(bar_index, year_low, bar_index + 50, year_low, 
                                  extend=extend.right, color=color.new(color.aqua, 0), 
                                  style=line.style_dashed, width=3)
        year_low_label := label.new(bar_index + 25, year_low, "12M", 
                                    color=color.new(color.aqua, 80), 
                                    textcolor=color.new(color.aqua, 0),
                                    style=label.style_label_center, 
                                    size=size.small)

// ============================================================================
// VOLUME TREND PANEL
// ============================================================================
trend_color(trend) =>
    trend == "HIGH" ? color.new(color.green, 0) : trend == "LOW" ? color.new(color.red, 0) : color.new(color.gray, 0)

trend_1m = get_volume_trend("1")
trend_5m = get_volume_trend("5")
trend_15m = get_volume_trend("15")
trend_30m = get_volume_trend("30")
trend_1h = get_volume_trend("60")
trend_4h = get_volume_trend("240")
trend_daily = get_volume_trend("D")
trend_weekly = get_volume_trend("W")
trend_monthly = get_volume_trend("M")

var table vol_panel = na

if show_volume_panel and barstate.islast
    vol_panel := table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 50))
    
    table.cell(vol_panel, 0, 0, "T/F", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(vol_panel, 1, 0, "VOL", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    
    table.cell(vol_panel, 0, 1, "1m", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 1, trend_1m, text_color=trend_color(trend_1m), text_size=size.small)
    table.cell(vol_panel, 0, 2, "5m", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 2, trend_5m, text_color=trend_color(trend_5m), text_size=size.small)
    table.cell(vol_panel, 0, 3, "15m", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 3, trend_15m, text_color=trend_color(trend_15m), text_size=size.small)
    table.cell(vol_panel, 0, 4, "30m", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 4, trend_30m, text_color=trend_color(trend_30m), text_size=size.small)
    table.cell(vol_panel, 0, 5, "1h", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 5, trend_1h, text_color=trend_color(trend_1h), text_size=size.small)
    table.cell(vol_panel, 0, 6, "4h", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 6, trend_4h, text_color=trend_color(trend_4h), text_size=size.small)
    table.cell(vol_panel, 0, 7, "D", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 7, trend_daily, text_color=trend_color(trend_daily), text_size=size.small)
    table.cell(vol_panel, 0, 8, "W", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 8, trend_weekly, text_color=trend_color(trend_weekly), text_size=size.small)
    table.cell(vol_panel, 0, 9, "M", text_color=color.white, text_size=size.small)
    table.cell(vol_panel, 1, 9, trend_monthly, text_color=trend_color(trend_monthly), text_size=size.small)
````
