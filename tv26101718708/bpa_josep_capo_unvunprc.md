# BPA Josep Capo

- url: https://www.tradingview.com/script/Unvunprc-BPA-Josep-Capo/
- type: indicator
- pine_id: PUB;c1557b69217d47319b87243bbf730b03
- version: 1.0

## Description

This is a Price Action tool designed to streamline chart reading by combining dynamic range tracking, key candlestick patterns, and quantitative context into a single clean overlay.

Key Features

Dynamic Range Tracker (ADR / AWR / AMR): Automatically calculates the 20-period average absolute High-Low range for your selected timeframe (Daily, Weekly, or Monthly) and displays it in a clean on-screen table.

ABR (Average Bar Range): Tracks the average High-Low range over the previous 5 periods on your current chart.

Surprise Bars: Optional color-coding for high-momentum candles exceeding 11% of your selected average range (Lime for bullish, Purple for bearish). Disabled by default.

Intraday Bar Counter: Automatically counts intraday bars per session and highlights hourly closing candles to help maintain session context and timing.

Inside & Outside Bar Detection: Places clean visual cues beneath bars to mark price compression and expansion (Triangles for Inside Bars, Circles for Outside Bars).

Multi-Timeframe EMAs: Plots the current chart 20 EMA alongside optional 15-minute and 60-minute 20 EMAs for quick higher-timeframe trend checks.

How to Use

Select your primary context framework (Daily, Weekly, or Monthly) in the script settings based on your trading style.

Monitor the top-right table to compare current bar volatility (ABR) against overall timeframe expectations (ADR/AWR/AMR).

Toggle Highlight Surprise Bars in the settings if you want visual cues for sudden breakout candles.

Developed for Al Brooks' price action trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©PriceActionHispano

//@version=6
indicator("BPA Josep Capo", overlay=true, max_labels_count=500)

// ==========================================
// --- CONFIGURATION INPUTS ---
// ==========================================

// 1. Current Chart EMA Settings
grp_ema_curr = "Current Chart EMA"
show_current_ema = input.bool(true, title="Show Current EMA", group=grp_ema_curr)
ema_length       = input.int(20, title="EMA Length", group=grp_ema_curr)
ema_color        = input.color(color.blue, title="Current EMA Color", group=grp_ema_curr)

// 2. Higher Timeframe (HTF) EMAs Settings
grp_htf = "Higher Timeframe (HTF) EMAs"
show_15m_ema = input.bool(false, title="Show EMA 20 (15 min)", tooltip="Visible only if checked", group=grp_htf)
color_15m    = input.color(color.orange, title="15m EMA Color", group=grp_htf)
show_60m_ema = input.bool(false, title="Show EMA 20 (60 min)", tooltip="Visible only if checked", group=grp_htf)
color_60m    = input.color(color.purple, title="60m EMA Color", group=grp_htf)

// 3. Bar Counter Settings
grp_bc = "Bar Counter"
showBarCount  = input.bool(true, "Show Bar Counter", group=grp_bc)
bcSizeOption  = input.string("Small", title="Text Size", options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"], group=grp_bc)
bcColor       = input.color(color.green, "Standard Text Color", group=grp_bc)
bcHourlyColor = input.color(color.red, "Hourly Close Color (Bar 12)", group=grp_bc)
bcInterval    = input.int(4, title="Show Every X Bars", group=grp_bc)

// 4. Pattern Settings (Inside / Outside Bars)
grp_pat = "Candlestick Patterns"
show_patterns = input.bool(true, "Show Symbols (Triangle/Circle)", group=grp_pat)

// 5. Framework & Average Range Settings
grp_info = "Information & Range Settings"
framework_option = input.string("Weekly", title="Time Framework", options=["Daily", "Weekly", "Monthly"], group=grp_info)

// 6. Surprise Bars Settings
grp_sb = "Surprise Bars"
enable_surprise_bars = input.bool(false, title="Highlight Surprise Bars", group=grp_sb)

// 7. Timeframe Separator Settings
grp_sep = "Timeframe Separator"
show_separator = input.bool(true, title="Show Timeframe Separator", group=grp_sep)
sep_color      = input.color(color.new(color.gray, 50), title="Line Color", group=grp_sep)
sep_style_opt  = input.string("Dashed", title="Line Style", options=["Dashed", "Dotted", "Solid"], group=grp_sep)
sep_width      = input.int(1, title="Line Width", minval=1, maxval=5, group=grp_sep)


// ==========================================
// --- AVERAGE RANGE CALCULATION ---
// ==========================================

tf_code = framework_option == "Daily" ? "D" : framework_option == "Weekly" ? "W" : "M"
range_label = framework_option == "Daily" ? "ADR" : framework_option == "Weekly" ? "AWR" : "AMR"

// Calculate 20-period average bar range (High - Low) for selected timeframe
avg_range_val = request.security(syminfo.tickerid, tf_code, ta.sma(high - low, 20), barmerge.gaps_off, barmerge.lookahead_off)


// ==========================================
// --- TIMEFRAME SEPARATOR LOGIC ---
// ==========================================

line_style_val = sep_style_opt == "Dashed" ? line.style_dashed : sep_style_opt == "Dotted" ? line.style_dotted : line.style_solid
is_period_change = ta.change(time(tf_code)) != 0

if show_separator and is_period_change and not na(time[1])
    line.new(x1=bar_index - 1, y1=low[1], x2=bar_index - 1, y2=high[1], extend=extend.both, color=sep_color, style=line_style_val, width=sep_width)


// ==========================================
// --- EMA CALCULATIONS AND PLOTTING ---
// ==========================================

// Current chart EMA
current_ema = ta.ema(close, ema_length)
plot(show_current_ema ? current_ema : na, title="Current Chart EMA", color=ema_color, linewidth=1)

// Higher timeframe (HTF) EMAs
ema_15m_val = request.security(syminfo.tickerid, "15", ta.ema(close, 20), barmerge.gaps_off)
ema_60m_val = request.security(syminfo.tickerid, "60", ta.ema(close, 20), barmerge.gaps_off)

plot(show_15m_ema ? ema_15m_val : na, title="EMA 20 (15m)", color=color_15m, linewidth=2)
plot(show_60m_ema ? ema_60m_val : na, title="EMA 20 (60m)", color=color_60m, linewidth=2)


// ==========================================
// --- BAR COUNTER LOGIC ---
// ==========================================

bcLabelSize = (bcSizeOption == "Huge") ? size.huge : (bcSizeOption == "Large") ? size.large : (bcSizeOption == "Small") ? size.small : (bcSizeOption == "Tiny") ? size.tiny : (bcSizeOption == "Auto") ? size.auto : size.normal

bool is_new_day = ta.change(time("D")) > 0
var int bar_count = 1
is_ltf = timeframe.isintraday and timeframe.in_seconds() <= 3600 

if is_new_day
    bar_count := 1
else if is_ltf
    bar_count += 1

if showBarCount and is_ltf
    if is_new_day or (bar_count % bcInterval == 0)
        lbl_col = (bar_count % 12 == 0) ? bcHourlyColor : bcColor
        label.new(bar_index, na, text=str.tostring(bar_count), color=color.new(color.white, 100), textcolor=lbl_col, style=label.style_label_up, size=bcLabelSize, yloc=yloc.belowbar)


// ==========================================
// --- PATTERN DETECTION (Triangles & Circles) ---
// ==========================================

is_inside  = high < high[1] and low > low[1]
is_outside = (high > high[1] and low < low[1]) or (high > high[1] and low == low[1]) or (high == high[1] and low < low[1])

plotshape(show_patterns and is_inside,  title="Inside Bar (Triangle)", style=shape.triangleup, location=location.belowbar, color=color.black, size=size.tiny)
plotshape(show_patterns and is_outside, title="Outside Bar (Circle)",   style=shape.circle,     location=location.belowbar, color=color.black, size=size.tiny)


// ==========================================
// --- METRICS & INFORMATION TABLE ---
// ==========================================

// Average high-low range of the previous 5 periods
abr = ta.sma(high - low, 5)

// Table creation (2 columns, 3 rows)
var table info_table = table.new(position.top_right, 2, 3, border_width = 1, border_color = color.gray, frame_width = 1, frame_color = color.gray)

if barstate.islast
    bg_col_title = color.new(color.gray, 80)
    bg_col_val   = color.new(color.blue, 90)
    txt_col      = chart.fg_color

    // Dynamic Range row (ADR / AWR / AMR)
    table.cell(info_table, 0, 0, range_label, bgcolor=bg_col_title, text_color=txt_col)
    table.cell(info_table, 1, 0, str.tostring(avg_range_val, "#.##"), bgcolor=bg_col_val, text_color=txt_col)

    // ABR row
    table.cell(info_table, 0, 1, "ABR", bgcolor=bg_col_title, text_color=txt_col)
    table.cell(info_table, 1, 1, str.tostring(abr, "#.##"), bgcolor=bg_col_val, text_color=txt_col)

    // Credits row
    table.cell(info_table, 0, 2, "www.josepcapo.com", text_size=size.large, text_color=color.blue)
    table.merge_cells(info_table, 0, 2, 1, 2)


// ==========================================
// --- SURPRISE BARS (>10% Range) ---
// ==========================================

bar_size = high - low
threshold = avg_range_val * 0.10

is_bull_bar = close > open
is_bear_bar = close < open

bar_col = enable_surprise_bars and (bar_size >= threshold) ? (is_bull_bar ? color.lime : (is_bear_bar ? color.purple : na)) : na

barcolor(bar_col, title="Surprise Bars")
````
