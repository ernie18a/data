# Bigul Price Action Analysis by AnkitGupta

- url: https://www.tradingview.com/script/J3Jelj20-Bigul-Price-Action-Analysis-by-AnkitGupta/
- type: indicator
- pine_id: PUB;3798733255a94acab5cd0efa26c766f4
- version: 1.0

## Description

What is this script?
It's a all-in-one trading analysis tool for Indian markets (NSE/BSE), built on top of TradingView. It draws key price levels, zones, and a summary table directly on your chart so you don't need 5 separate indicators.

📦 What's inside — in simple words
1. CPR (Central Pivot Range)
The most important part of the script. CPR is calculated from yesterday's High, Low, and Close. It gives you 3 lines:

Pivot (P) — the middle, acts like a magnet for price
Top CPR (TC) — upper boundary
Bottom CPR (BC) — lower boundary

If price opens above CPR → likely bullish day. Below → likely bearish. Inside → sideways/choppy day expected.
You can switch between 4 methods: Traditional, Fibonacci, Classic, Camarilla.

2. Support & Resistance Levels (S1–S5 / R1–R5)
These are price levels above (Resistance) and below (Support) the CPR where price is likely to pause, reverse, or break out. Think of them as speed bumps on the road of price movement.

3. Developing CPR
Shows you what tomorrow's CPR will look like based on today's price action so far — updates live as the day progresses. Useful for planning the next day's trades before market close.

4. Previous Day High / Low (PH / PL)
Draws horizontal lines at yesterday's highest and lowest price. These are very important levels — breaks above PH are bullish signals, breaks below PL are bearish.

5. Day Open
A simple line showing where today's market opened. Price respecting or rejecting this level tells you a lot about intraday sentiment.

6. Moving Averages (MA 1–5)
You can turn on up to 5 moving averages (EMA, SMA, WMA etc.) with custom lengths and colors. These help you identify the overall trend direction.

7. Day-Open Anchored VWAP
VWAP = Volume Weighted Average Price. This version resets every morning at market open. It tells you the average price paid by all traders today. Price above VWAP = bulls in control. Below = bears in control. Professional traders watch this closely.

8. Initial Balance (IB)
The first hour of trading (9:15–10:15 AM for NSE) sets the Initial Balance — the high and low of that first hour. The rest of the day often revolves around this range:

Price breaking above IB High → strong bullish momentum
Price breaking below IB Low → strong bearish momentum
Price staying inside → range-bound day


9. Bar Range Display
Shows the point range of each candle (High minus Low) directly on the chart. Useful to quickly spot unusually large candles — those often signal strong momentum or reversals.

10. Consolidation Zones (newly added)
Automatically detects when price is moving sideways (stuck in a range). It draws a shaded box around that zone. When price finally breaks out of this zone, it often leads to a strong directional move. The script fires an alert when a breakout happens.

11. The Info Table (top-right corner)
A small dashboard that summarises everything at a glance:
RowWhat it tells youTrust the Bulls/Bears/PatienceOverall trade bias based on CPR locationMonthly / Weekly / DailyIs price above, below, or inside CPR on each timeframe?OpenWhere did today's open land relative to CPR?NowWhere is current price relative to CPR & SR levels?CPR WidthNarrow CPR = trending day expected. Wide = choppyCPR TypeAscending/Descending/Inside etc. — helps predict tomorrowIBInitial Balance range in pointsRangeCurrent bar's range in pointsVol vs MAIs current volume higher or lower than average?

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
// © Bigul Price Action Analysis by AnkitGupta
// credits to ajithcpas, finallynitin
// modified from "CPR (Central Pivot Range)" script by ajithcpas https://www.tradingview.com/v/R6lRetr0/

//@version=6
indicator('Bigul Price Action Analysis by AnkitGupta', shorttitle = 'Bigul PA - AnkitGupta', overlay = true, max_lines_count = 500, max_labels_count = 500)

AUTO = 'Auto'
DAILY = 'Daily'
WEEKLY = 'Weekly'
MONTHLY = 'Monthly'
QUARTERLY = 'Quarterly'
HALF_YEARLY = 'Half-yearly'
YEARLY = 'Yearly'

TRADITIONAL = 'Traditional'
FIBONACCI = 'Fibonacci'
CLASSIC = 'Classic'
CAMARILLA = 'Camarilla'

// Input fields
kind = input.string(title = 'Type', defval = TRADITIONAL, options = [TRADITIONAL, FIBONACCI, CLASSIC, CAMARILLA])
cpr_time_frame = input.string(title = 'CPR Timeframe', defval = AUTO, options = [AUTO, DAILY, WEEKLY, MONTHLY, QUARTERLY, HALF_YEARLY, YEARLY])
look_back = input.int(title = 'Number of CPR Back', defval = 3, minval = 1, maxval = 5000)
position_labels = input.string('Right', 'Labels Position', options = ['Left', 'Right'])
line_width = input.int(title = 'Line Width', defval = 3, minval = 1, maxval = 100)
hist_sr_show = input.bool(false, 'Show Historical SR Pivots')
is_daily_based = input.bool(title = 'Use Daily-based Values', defval = true, tooltip = 'When this option is unchecked, CPR will use intraday data while calculating on intraday charts. If Extended Hours are displayed on the chart, they will be taken into account during the CPR level calculation. If intraday OHLC values are different from daily-based values (normal for stocks), the CPR levels will also differ.')

// Variables
var arr_time = array.new_int()
var p = array.new_float()
var tp = array.new_float()
var bp = array.new_float()
var SR_COLOR = #FB8C00
var DEV_SR_COLOR = #E2BEE7
var pdh_arr = array.new_float()
var pdl_arr = array.new_float()

// ——— CPR Customisation ———
cpr_show = input.bool(true, '', inline = 'CPR', group = 'CPR Customisation')
cpr_color = input.color(color.blue, 'Show CPR', inline = 'CPR', group = 'CPR Customisation')
cpr_show_lines = input.bool(true, 'Show CPR Lines', group = 'CPR Customisation')
cpr_show_fill = input.bool(false, 'Show CPR Fill', group = 'CPR Customisation')
cpr_show_prices = input.bool(false, 'Show CPR Price', group = 'CPR Customisation')
cpr_show_labels = input.bool(false, 'Show CPR Label', group = 'CPR Customisation')
cpr_line_style = input.string('Dotted', 'CPR Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'CPR Customisation')

// ——— Pivot Customisation ———
sr_show = input.bool(true, 'Show SR Levels', inline = 'Show SR Pivots', group = 'Pivot Customisation')
sr_show_labels = input.bool(true, 'Show SR Label', group = 'Pivot Customisation')
sr_show_prices = input.bool(true, 'Show SR Price', group = 'Pivot Customisation')

// ——— Pivots ———
var r0_5 = array.new_float()
var s0_5 = array.new_float()
s0_5_show = input.bool(false, '', inline = 'S0.5/R0.5', group = 'Pivot Display')
s0_5_color = input.color(SR_COLOR, 'S0.5', inline = 'S0.5/R0.5', group = 'Pivot Display')
r0_5_show = input.bool(false, '', inline = 'S0.5/R0.5', group = 'Pivot Display')
r0_5_color = input.color(SR_COLOR, 'R0.5', inline = 'S0.5/R0.5', group = 'Pivot Display')
var r1 = array.new_float()
var s1 = array.new_float()
s1_show = input.bool(true, '', inline = 'S1/R1', group = 'Pivot Display')
s1_color = input.color(SR_COLOR, 'S1', inline = 'S1/R1', group = 'Pivot Display')
r1_show = input.bool(true, '', inline = 'S1/R1', group = 'Pivot Display')
r1_color = input.color(SR_COLOR, 'R1', inline = 'S1/R1', group = 'Pivot Display')
var r1_5 = array.new_float()
var s1_5 = array.new_float()
s1_5_show = input.bool(false, '', inline = 'S1.5/R1.5', group = 'Pivot Display')
s1_5_color = input.color(SR_COLOR, 'S1.5', inline = 'S1.5/R1.5', group = 'Pivot Display')
r1_5_show = input.bool(false, '', inline = 'S1.5/R1.5', group = 'Pivot Display')
r1_5_color = input.color(SR_COLOR, 'R1.5', inline = 'S1.5/R1.5', group = 'Pivot Display')
var r2 = array.new_float()
var s2 = array.new_float()
s2_show = input.bool(false, '', inline = 'S2/R2', group = 'Pivot Display')
s2_color = input.color(SR_COLOR, 'S2', inline = 'S2/R2', group = 'Pivot Display')
r2_show = input.bool(false, '', inline = 'S2/R2', group = 'Pivot Display')
r2_color = input.color(SR_COLOR, 'R2', inline = 'S2/R2', group = 'Pivot Display')
var r2_5 = array.new_float()
var s2_5 = array.new_float()
s2_5_show = input.bool(false, '', inline = 'S2.5/R2.5', group = 'Pivot Display')
s2_5_color = input.color(SR_COLOR, 'S2.5', inline = 'S2.5/R2.5', group = 'Pivot Display')
r2_5_show = input.bool(false, '', inline = 'S2.5/R2.5', group = 'Pivot Display')
r2_5_color = input.color(SR_COLOR, 'R2.5', inline = 'S2.5/R2.5', group = 'Pivot Display')
var r3 = array.new_float()
var s3 = array.new_float()
s3_show = input.bool(false, '', inline = 'S3/R3', group = 'Pivot Display')
s3_color = input.color(SR_COLOR, 'S3', inline = 'S3/R3', group = 'Pivot Display')
r3_show = input.bool(false, '', inline = 'S3/R3', group = 'Pivot Display')
r3_color = input.color(SR_COLOR, 'R3', inline = 'S3/R3', group = 'Pivot Display')
var r3_5 = array.new_float()
var s3_5 = array.new_float()
s3_5_show = input.bool(false, '', inline = 'S3.5/R3.5', group = 'Pivot Display')
s3_5_color = input.color(SR_COLOR, 'S3.5', inline = 'S3.5/R3.5', group = 'Pivot Display')
r3_5_show = input.bool(false, '', inline = 'S3.5/R3.5', group = 'Pivot Display')
r3_5_color = input.color(SR_COLOR, 'R3.5', inline = 'S3.5/R3.5', group = 'Pivot Display')
var r4 = array.new_float()
var s4 = array.new_float()
s4_show = input.bool(false, '', inline = 'S4/R4', group = 'Pivot Display')
s4_color = input.color(SR_COLOR, 'S4', inline = 'S4/R4', group = 'Pivot Display')
r4_show = input.bool(false, '', inline = 'S4/R4', group = 'Pivot Display')
r4_color = input.color(SR_COLOR, 'R4', inline = 'S4/R4', group = 'Pivot Display')
var r4_5 = array.new_float()
var s4_5 = array.new_float()
s4_5_show = input.bool(false, '', inline = 'S4.5/R4.5', group = 'Pivot Display')
s4_5_color = input.color(SR_COLOR, 'S4.5', inline = 'S4.5/R4.5', group = 'Pivot Display')
r4_5_show = input.bool(false, '', inline = 'S4.5/R4.5', group = 'Pivot Display')
r4_5_color = input.color(SR_COLOR, 'R4.5', inline = 'S4.5/R4.5', group = 'Pivot Display')
var r5 = array.new_float()
var s5 = array.new_float()
s5_show = input.bool(false, '', inline = 'S5/R5', group = 'Pivot Display')
s5_color = input.color(SR_COLOR, 'S5', inline = 'S5/R5', group = 'Pivot Display')
r5_show = input.bool(false, '', inline = 'S5/R5', group = 'Pivot Display')
r5_color = input.color(SR_COLOR, 'R5', inline = 'S5/R5', group = 'Pivot Display')

// ——— Developing CPR ———
dev_cpr_show = input.bool(false, '', inline = 'Dev CPR', group = 'Developing CPR levels')
dev_cpr_color = input.color(DEV_SR_COLOR, 'Dev CPR', inline = 'Dev CPR', group = 'Developing CPR levels')
var dev_r1 = array.new_float()
var dev_s1 = array.new_float()
dev_s1_show = input.bool(false, '', inline = 'S1/R1', group = 'Developing CPR levels')
dev_s1_color = input.color(DEV_SR_COLOR, 'S1', inline = 'S1/R1', group = 'Developing CPR levels')
dev_r1_show = input.bool(false, '', inline = 'S1/R1', group = 'Developing CPR levels')
dev_r1_color = input.color(DEV_SR_COLOR, 'R1', inline = 'S1/R1', group = 'Developing CPR levels')
extend_dev_cpr_line = input.bool(false, '', inline = 'extend', group = 'Developing CPR levels')

dev_cpr_show_labels = input.bool(true, 'Show Dev CPR Labels', group = 'Developing CPR levels')
dev_cpr_show_prices = input.bool(false, 'Show Dev CPR Price Levels', group = 'Developing CPR levels')
dev_r1_show_labels = input.bool(true, 'Show Dev R1 Labels', group = 'Developing CPR levels')
dev_r1_show_prices = input.bool(false, 'Show Dev R1 Price Levels', group = 'Developing CPR levels')
dev_s1_show_labels = input.bool(true, 'Show Dev S1 Labels', group = 'Developing CPR levels')
dev_s1_show_prices = input.bool(false, 'Show Dev S1 Price Levels', group = 'Developing CPR levels')

// — Group for CPR↔SR fill —
fill_cpr_r1     = input.bool(false,    'Fill CPR → R1',        group='Pivot Customisation')
fill_cpr_r1_col = input.color(color.new(color.orange, 75), 'CPR–R1 Fill Color',    group='Pivot Customisation')
fill_cpr_s1     = input.bool(false,    'Fill CPR → S1',        group='Pivot Customisation')
fill_cpr_s1_col = input.color(color.new(color.orange, 75), 'CPR–S1 Fill Color',    group='Pivot Customisation')

dev_cpr_line_days = input.int(title = 'Extend line by days', defval = 1, minval = 1, maxval = 10, inline = 'extend', group = 'Developing CPR levels', tooltip = 'Enable this when the Dev CPR lines are not visible(i.e. there is a trading holiday in upcoming session).')
check_holidays = input.bool(true, 'Check NSE/BSE holidays', group = 'Developing CPR levels', tooltip = 'Enable this when the Dev CPR lines are not visible(i.e. there is a trading holiday in upcoming session).')

// --- Session Display Toggles ---
show_day = input.bool(false, title = 'Show Previous High/Low', group = 'Session High Low')
session_hl_line_style = input.string(defval = 'Solid', title = 'Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = 'Session High Low')
show_day_open = input.bool(defval = false, title = 'Show Current Day', group = 'Session Open')
session_high_color = input.color(defval = color.aqua , title = 'High Line Color', group = 'Session High Low')
session_low_color = input.color(defval = color.aqua, title = 'Low Line Color', group = 'Session High Low')
session_open_color = input.color(defval = color.aqua, title = 'Line Color', group = 'Session Open')
session_open_line_style = input.string(defval = 'Dashed', title = 'Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = 'Session Open')

// --- PDH/PDL label/price toggles ---
pd_show_labels = input.bool(true,  'Show PH/PL Labels', group='Session High Low')
pd_show_prices = input.bool(true,  'Show PH/PL Prices', group='Session High Low')

// ——— Series state ———
pivotX_open = float(na)
pivotX_open := nz(pivotX_open[1], open)
pivotX_high = float(na)
pivotX_high := nz(pivotX_high[1], high)
pivotX_low = float(na)
pivotX_low := nz(pivotX_low[1], low)
pivotX_prev_open = float(na)
pivotX_prev_open := nz(pivotX_prev_open[1])
pivotX_prev_high = float(na)
pivotX_prev_high := nz(pivotX_prev_high[1])
pivotX_prev_low = float(na)
pivotX_prev_low := nz(pivotX_prev_low[1])
pivotX_prev_close = float(na)
pivotX_prev_close := nz(pivotX_prev_close[1])

// ——— Helpers to pick CPR resolution ———
get_pivot_resolution() =>
    resolution = 'M'
    if cpr_time_frame == AUTO
        if timeframe.isintraday
            resolution := timeframe.multiplier <60 ? 'D' : 'W'
            resolution
        else if timeframe.isdaily
            resolution := 'M'
            resolution
        else if timeframe.isweekly
            resolution := '6M'
            resolution
        else
            resolution := '12M'
            resolution
    else if cpr_time_frame == DAILY
        resolution := 'D'
        resolution
    else if cpr_time_frame == WEEKLY
        resolution := 'W'
        resolution
    else if cpr_time_frame == MONTHLY
        resolution := 'M'
        resolution
    else if cpr_time_frame == QUARTERLY
        resolution := '3M'
        resolution
    else if cpr_time_frame == HALF_YEARLY
        resolution := '6M'
        resolution
    else if cpr_time_frame == YEARLY
        resolution := '12M'
        resolution
    resolution

// ——— Draw state ———
var lines = array.new_line()
var labels = array.new_label()


can_draw(a, i) =>
    i >= 0 and i < array.size(a) and not na(array.get(a, i))

val_at(a, i) =>
    can_draw(a, i) ? array.get(a, i) : na

draw_line(i, pivot, col, line_style = line.style_solid) =>
    line aLine = na
    okArrTime = array.size(arr_time) > 1 and i >= 0 and i < array.size(arr_time) - 1
    okPivot   = i >= 0 and i < array.size(pivot)
    if okArrTime and okPivot
        y = array.get(pivot, i)
        if not na(y)
            aLine := line.new(array.get(arr_time, i),y,array.get(arr_time, i + 1), y,xloc = xloc.bar_time, color = col, width = line_width, style = line_style)
            array.push(lines, aLine)
    aLine

// ——— Draw label ———
draw_label(i, y, txt, txt_color, is_cpr = false, is_sr = false) =>
    if na(y)
        na
    else
        _showLbl = is_cpr ? cpr_show_labels : is_sr ? sr_show_labels : true
        _showPrc = is_cpr ? cpr_show_prices : is_sr ? sr_show_prices : true
        if _showLbl or _showPrc
            display = ''
            if _showLbl and _showPrc and txt != ''
                display := str.format('                                {0} - {1}', txt, math.round_to_mintick(y))
            else if _showLbl and txt != ''
                display := '                           ' + txt
            else
                display := str.format('                                {0}', math.round_to_mintick(y))
            rightIndex = math.min(i + 1, array.size(arr_time) - 1)
            leftIndex  = math.min(i,     array.size(arr_time) - 1)
            if rightIndex >= 0 and leftIndex >= 0
                x = position_labels == 'Left' ? array.get(arr_time, leftIndex) : array.get(arr_time, rightIndex)
                array.push(labels, label.new(x = x, y = y, text = display, textcolor = txt_color, style = label.style_none, color = #00000000, xloc = xloc.bar_time))

pd_label_text(_name, _price, _showLbl, _showPrc) =>
    txt = ''
    if _showLbl and _showPrc
        txt := str.format('                                {0} - {1}', _name, math.round_to_mintick(_price))
    else if _showLbl
        txt := '                                ' + _name
    else if _showPrc
        txt := str.format('                                {0}', math.round_to_mintick(_price))
    txt

traditional() =>
    pivotX_Median = (pivotX_prev_high + pivotX_prev_low + pivotX_prev_close) / 3
    _r1 = pivotX_Median * 2 - pivotX_prev_low
    _s1 = pivotX_Median * 2 - pivotX_prev_high
    _r2 = pivotX_Median + 1 * (pivotX_prev_high - pivotX_prev_low)
    _s2 = pivotX_Median - 1 * (pivotX_prev_high - pivotX_prev_low)
    _r3 = _r1 + pivotX_prev_high - pivotX_prev_low
    _s3 = _s1 - pivotX_prev_high + pivotX_prev_low
    _r4 = _r3 + _r2 - _r1
    _s4 = _s3 + _s2 - _s1
    _r5 = _r4 + _r3 - _r2
    _s5 = _s4 + _s3 - _s2
    array.push(r0_5, (pivotX_Median + _r1) / 2)
    array.push(s0_5, (pivotX_Median + _s1) / 2)
    array.push(r1, _r1)
    array.push(s1, _s1)
    array.push(r1_5, (_r1 + _r2) / 2)
    array.push(s1_5, (_s1 + _s2) / 2)
    array.push(r2, _r2)
    array.push(s2, _s2)
    array.push(r2_5, (_r2 + _r3) / 2)
    array.push(s2_5, (_s2 + _s3) / 2)
    array.push(r3, _r3)
    array.push(s3, _s3)
    array.push(r3_5, (_r3 + _r4) / 2)
    array.push(s3_5, (_s3 + _s4) / 2)
    array.push(r4, _r4)
    array.push(s4, _s4)
    array.push(r4_5, (_r4 + _r5) / 2)
    array.push(s4_5, (_s4 + _s5) / 2)
    array.push(r5, _r5)
    array.push(s5, _s5)

fibonacci() =>
    pivotX_Median = (pivotX_prev_high + pivotX_prev_low + pivotX_prev_close) / 3
    pivot_range = pivotX_prev_high - pivotX_prev_low
    array.push(r1, pivotX_Median + 0.382 * pivot_range)
    array.push(s1, pivotX_Median - 0.382 * pivot_range)
    array.push(r2, pivotX_Median + 0.618 * pivot_range)
    array.push(s2, pivotX_Median - 0.618 * pivot_range)
    array.push(r3, pivotX_Median + 1 * pivot_range)
    array.push(s3, pivotX_Median - 1 * pivot_range)

classic() =>
    pivotX_Median = (pivotX_prev_high + pivotX_prev_low + pivotX_prev_close) / 3
    pivot_range = pivotX_prev_high - pivotX_prev_low
    array.push(r1, pivotX_Median * 2 - pivotX_prev_low)
    array.push(s1, pivotX_Median * 2 - pivotX_prev_high)
    array.push(r2, pivotX_Median + 1 * pivot_range)
    array.push(s2, pivotX_Median - 1 * pivot_range)
    array.push(r3, pivotX_Median + 2 * pivot_range)
    array.push(s3, pivotX_Median - 2 * pivot_range)
    array.push(r4, pivotX_Median + 3 * pivot_range)
    array.push(s4, pivotX_Median - 3 * pivot_range)

camarilla() =>
    pivotX_Median = (pivotX_prev_high + pivotX_prev_low + pivotX_prev_close) / 3
    pivot_range = pivotX_prev_high - pivotX_prev_low
    array.push(r1, pivotX_prev_close + pivot_range * 1.1 / 12.0)
    array.push(s1, pivotX_prev_close - pivot_range * 1.1 / 12.0)
    array.push(r2, pivotX_prev_close + pivot_range * 1.1 / 6.0)
    array.push(s2, pivotX_prev_close - pivot_range * 1.1 / 6.0)
    array.push(r3, pivotX_prev_close + pivot_range * 1.1 / 4.0)
    array.push(s3, pivotX_prev_close - pivot_range * 1.1 / 4.0)
    array.push(r4, pivotX_prev_close + pivot_range * 1.1 / 2.0)
    array.push(s4, pivotX_prev_close - pivot_range * 1.1 / 2.0)
    r5_val = pivotX_prev_high / pivotX_prev_low * pivotX_prev_close
    array.push(r5, r5_val)
    array.push(s5, 2 * pivotX_prev_close - r5_val)


// ——— Get CPR timeframe resolution and prev-period H/L
resolution = get_pivot_resolution()
pdHighSer = request.security(syminfo.tickerid, resolution, high[1], lookahead = barmerge.lookahead_on)
pdLowSer  = request.security(syminfo.tickerid, resolution, low[1],  lookahead = barmerge.lookahead_on)


calc_pivot() =>
    pivotX_Median = (pivotX_prev_high + pivotX_prev_low + pivotX_prev_close) / 3
    pivotX_Bottom = (pivotX_prev_high + pivotX_prev_low) / 2
    pivotX_Top = pivotX_Median * 2 - pivotX_Bottom
    if pivotX_Bottom > pivotX_Top
        temp = pivotX_Bottom
        pivotX_Bottom := pivotX_Top
        pivotX_Top := temp
        pivotX_Top
    array.push(p, pivotX_Median)
    array.push(tp, pivotX_Top)
    array.push(bp, pivotX_Bottom)
    array.push(pdh_arr, pdHighSer)
    array.push(pdl_arr, pdLowSer)
    if kind == TRADITIONAL
        traditional()
    else if kind == FIBONACCI
        fibonacci()
    else if kind == CLASSIC
        classic()
    else if kind == CAMARILLA
        camarilla()



calc_high(prev, curr) =>
    if na(prev) or na(curr)
        nz(prev, nz(curr, na))
    else
        math.max(prev, curr)

calc_low(prev, curr) =>
    if not na(prev) and not na(curr)
        math.min(prev, curr)
    else
        nz(prev, nz(curr, na))

[sec_open, sec_high, sec_low, prev_sec_open, prev_sec_high, prev_sec_low, prev_sec_close, prev_sec_time] = request.security(syminfo.tickerid, resolution, [open, high, low, open[1], high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)

sec_open_gaps_on = request.security(syminfo.tickerid, resolution, open, gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_on)

var is_change = false
var uses_current_bar = false
var change_time = int(na)
is_time_change = ta.change(time(resolution)) != 0
if is_time_change
    change_time := time
    change_time

var start_time = time
without_time_change = barstate.islast and array.size(arr_time) == 0
is_can_calc_pivot = not uses_current_bar and is_time_change or uses_current_bar and not na(sec_open_gaps_on) or without_time_change
enough_bars_for_calculate = prev_sec_time >= start_time or is_daily_based

if is_can_calc_pivot and enough_bars_for_calculate
    if array.size(arr_time) == 0 and is_daily_based
        pivotX_prev_open := prev_sec_open[1]
        pivotX_prev_high := prev_sec_high[1]
        pivotX_prev_low := prev_sec_low[1]
        pivotX_prev_close := prev_sec_close[1]
        pivotX_open := sec_open[1]
        pivotX_high := sec_high[1]
        pivotX_low := sec_low[1]
        array.push(arr_time, start_time)
        calc_pivot()

    if is_daily_based
        pivotX_prev_open := prev_sec_open
        pivotX_prev_high := prev_sec_high
        pivotX_prev_low := prev_sec_low
        pivotX_prev_close := prev_sec_close
        pivotX_open := sec_open
        pivotX_high := sec_high
        pivotX_low := sec_low
        pivotX_low
    else
        pivotX_prev_high := pivotX_high
        pivotX_prev_low := pivotX_low
        pivotX_prev_open := pivotX_open
        pivotX_prev_close := close[1]
        pivotX_open := open
        pivotX_high := high
        pivotX_low := low
        pivotX_low

    if barstate.islast and not is_change and array.size(arr_time) > 0 and not without_time_change
        array.set(arr_time, array.size(arr_time) - 1, change_time)
    else if without_time_change
        array.push(arr_time, start_time)
    else
        array.push(arr_time, nz(change_time, time))

    calc_pivot()

    if array.size(arr_time) > look_back
        if array.size(arr_time) > 0
            array.shift(arr_time)
        if array.size(p) > 0 and cpr_show
            array.shift(p)
        if array.size(tp) > 0 and cpr_show
            array.shift(tp)
        if array.size(bp) > 0 and cpr_show
            array.shift(bp)
        if array.size(pdh_arr) > 0
            array.shift(pdh_arr)
        if array.size(pdl_arr) > 0
            array.shift(pdl_arr)

        if sr_show or hist_sr_show
            if array.size(r0_5) > 0 and r0_5_show
                array.shift(r0_5)
            if array.size(s0_5) > 0 and s0_5_show
                array.shift(s0_5)
            if array.size(r1) > 0 and r1_show
                array.shift(r1)
            if array.size(s1) > 0 and s1_show
                array.shift(s1)
            if array.size(r1_5) > 0 and r1_5_show
                array.shift(r1_5)
            if array.size(s1_5) > 0 and s1_5_show
                array.shift(s1_5)
            if array.size(r2) > 0 and r2_show
                array.shift(r2)
            if array.size(s2) > 0 and s2_show
                array.shift(s2)
            if array.size(r2_5) > 0 and r2_5_show
                array.shift(r2_5)
            if array.size(s2_5) > 0 and s2_5_show
                array.shift(s2_5)
            if array.size(r3) > 0 and r3_show
                array.shift(r3)
            if array.size(s3) > 0 and s3_show
                array.shift(s3)
            if array.size(r3_5) > 0 and r3_5_show
                array.shift(r3_5)
            if array.size(s3_5) > 0 and s3_5_show
                array.shift(s3_5)
            if array.size(r4) > 0 and r4_show
                array.shift(r4)
            if array.size(s4) > 0 and s4_show
                array.shift(s4)
            if array.size(r4_5) > 0 and r4_5_show
                array.shift(r4_5)
            if array.size(s4_5) > 0 and s4_5_show
                array.shift(s4_5)
            if array.size(r5) > 0 and r5_show
                array.shift(r5)
            if array.size(s5) > 0 and s5_show
                array.shift(s5)
    is_change := true
    is_change
else if not is_daily_based
    pivotX_high := math.max(pivotX_high, high)
    pivotX_low := math.min(pivotX_low, low)
    pivotX_low

if barstate.islast and not is_daily_based and array.size(arr_time) == 0
    runtime.error('Not enough intraday data to calculate CPR. Lower the CPR Timeframe or turn on the \'Use Daily-based Values\' option in the indicator settings.')

if barstate.islast and array.size(arr_time) > 0 and is_change
    is_change := false
    array.push(arr_time, time_close(resolution))

    for idx = 0 to array.size(lines) - 1 by 1
        if array.size(lines) > 0
            line.delete(array.shift(lines))
        if array.size(labels) > 0
            label.delete(array.shift(labels))

    line cpLine = na
    line r1Line = na
    line s1Line = na

    j = array.size(arr_time) - 2

    for idx = 0 to j by 1
        style_cpr = cpr_line_style == 'Solid'  ? line.style_solid : cpr_line_style == 'Dashed' ? line.style_dashed : line.style_dotted

        if array.size(p) > 0 and cpr_show and can_draw(p, idx)
            cpLine := draw_line(idx, p, cpr_show_lines ? cpr_color : color.new(cpr_color, 100), style_cpr)

        line tp_line = na
        line bp_line = na
        if array.size(tp) > 0 and array.size(bp) > 0 and cpr_show and can_draw(tp, idx) and can_draw(bp, idx)
            tp_line := draw_line(idx, tp, cpr_show_lines ? cpr_color : color.new(cpr_color, 100), style_cpr)
            bp_line := draw_line(idx, bp, cpr_show_lines ? cpr_color : color.new(cpr_color, 100), style_cpr)
            if cpr_show_fill and not na(tp_line) and not na(bp_line)
                linefill.new(tp_line, bp_line, color.new(cpr_color, 70))

        // — draw R1 & S1 on the last bar and remember handles —
        if idx == j and sr_show
            if r1_show and can_draw(r1, idx)
                r1Line := draw_line(idx, r1, r1_color)
                draw_label(idx, val_at(r1, idx), 'R1', r1_color, false, true)
            if s1_show and can_draw(s1, idx)
                s1Line := draw_line(idx, s1, s1_color)
                draw_label(idx, val_at(s1, idx), 'S1', s1_color, false, true)

        // — fills between CPR middle-line and R1/S1 —
        if idx == j and cpr_show
            if fill_cpr_r1 and not na(cpLine) and not na(r1Line)
                linefill.new(cpLine, r1Line, fill_cpr_r1_col)
            if fill_cpr_s1 and not na(cpLine) and not na(s1Line)
                linefill.new(cpLine, s1Line, fill_cpr_r1_col)

// --- draw SR levels ---
    for idx = 0 to j by 1
        if hist_sr_show and idx < j or sr_show and idx == j
            // R0.5 / S0.5
            if r0_5_show and can_draw(r0_5, idx)
                draw_line(idx, r0_5, r0_5_color, line.style_dashed)
                draw_label(idx, val_at(r0_5, idx), 'R0.5', r0_5_color, false, true)
            if s0_5_show and can_draw(s0_5, idx)
                draw_line(idx, s0_5, s0_5_color, line.style_dashed)
                draw_label(idx, val_at(s0_5, idx), 'S0.5', s0_5_color, false, true)

            // R1 / S1 (historical too)
            if r1_show and can_draw(r1, idx)
                draw_line(idx, r1, r1_color)
                draw_label(idx, val_at(r1, idx), 'R1', r1_color, false, true)
            if s1_show and can_draw(s1, idx)
                draw_line(idx, s1, s1_color)
                draw_label(idx, val_at(s1, idx), 'S1', s1_color, false, true)

            // R1.5 / S1.5
            if r1_5_show and can_draw(r1_5, idx)
                draw_line(idx, r1_5, r1_5_color, line.style_dashed)
                draw_label(idx, val_at(r1_5, idx), 'R1.5', r1_5_color, false, true)
            if s1_5_show and can_draw(s1_5, idx)
                draw_line(idx, s1_5, s1_5_color, line.style_dashed)
                draw_label(idx, val_at(s1_5, idx), 'S1.5', s1_5_color, false, true)

            // R2 / S2
            if r2_show and can_draw(r2, idx)
                draw_line(idx, r2, r2_color)
                draw_label(idx, val_at(r2, idx), 'R2', r2_color, false, true)
            if s2_show and can_draw(s2, idx)
                draw_line(idx, s2, s2_color)
                draw_label(idx, val_at(s2, idx), 'S2', s2_color, false, true)

            // R2.5 / S2.5
            if r2_5_show and can_draw(r2_5, idx)
                draw_line(idx, r2_5, r2_5_color, line.style_dashed)
                draw_label(idx, val_at(r2_5, idx), 'R2.5', r2_5_color, false, true)
            if s2_5_show and can_draw(s2_5, idx)
                draw_line(idx, s2_5, s2_5_color, line.style_dashed)
                draw_label(idx, val_at(s2_5, idx), 'S2.5', s2_5_color, false, true)

            // R3 / S3
            if r3_show and can_draw(r3, idx)
                draw_line(idx, r3, r3_color)
                draw_label(idx, val_at(r3, idx), 'R3', r3_color, false, true)
            if s3_show and can_draw(s3, idx)
                draw_line(idx, s3, s3_color)
                draw_label(idx, val_at(s3, idx), 'S3', s3_color, false, true)

            // R3.5 / S3.5
            if r3_5_show and can_draw(r3_5, idx)
                draw_line(idx, r3_5, r3_5_color, line.style_dashed)
                draw_label(idx, val_at(r3_5, idx), 'R3.5', r3_5_color, false, true)
            if s3_5_show and can_draw(s3_5, idx)
                draw_line(idx, s3_5, s3_5_color, line.style_dashed)
                draw_label(idx, val_at(s3_5, idx), 'S3.5', s3_5_color, false, true)

            // R4 / S4
            if r4_show and can_draw(r4, idx)
                draw_line(idx, r4, r4_color)
                draw_label(idx, val_at(r4, idx), 'R4', r4_color, false, true)
            if s4_show and can_draw(s4, idx)
                draw_line(idx, s4, s4_color)
                draw_label(idx, val_at(s4, idx), 'S4', s4_color, false, true)

            // R4.5 / S4.5
            if r4_5_show and can_draw(r4_5, idx)
                draw_line(idx, r4_5, r4_5_color, line.style_dashed)
                draw_label(idx, val_at(r4_5, idx), 'R4.5', r4_5_color, false, true)
            if s4_5_show and can_draw(s4_5, idx)
                draw_line(idx, s4_5, s4_5_color, line.style_dashed)
                draw_label(idx, val_at(s4_5, idx), 'S4.5', s4_5_color, false, true)

            // R5 / S5
            if r5_show and can_draw(r5, idx)
                draw_line(idx, r5, r5_color)
                draw_label(idx, val_at(r5, idx), 'R5', r5_color, false, true)
            if s5_show and can_draw(s5, idx)
                draw_line(idx, s5, s5_color)
                draw_label(idx, val_at(s5, idx), 'S5', s5_color, false, true)

    i = array.size(arr_time) - 2
    if array.size(p) > 0 and cpr_show and can_draw(p, i)
        draw_label(i, val_at(p, i), 'CPR', cpr_color, true, false)
    if array.size(tp) > 0 and cpr_show and can_draw(tp, i)
        draw_label(i, val_at(tp, i), '', cpr_color, true, false)
    if array.size(bp) > 0 and cpr_show and can_draw(bp, i)
        draw_label(i, val_at(bp, i), '', cpr_color, true, false)

    // --- PDH / PDL limited to the last `look_back` CPR periods (no steplines) ---
    if show_day and array.size(arr_time) > 1 and array.size(pdh_arr) == array.size(p)
        pd_style = session_hl_line_style == 'Solid' ? line.style_solid :
                   session_hl_line_style == 'Dashed' ? line.style_dashed :
                   line.style_dotted

        start_idx = math.max(0, j - (look_back - 1))
        for k = start_idx to j
            if hist_sr_show or k == j
                if not na(array.get(pdh_arr, k))
                    line_pdH = line.new(x1 = array.get(arr_time, k), y1 = array.get(pdh_arr, k), x2 = array.get(arr_time, k + 1), y2 = array.get(pdh_arr, k),xloc = xloc.bar_time, color= session_high_color, width= line_width, style= pd_style)
                    array.push(lines, line_pdH)

                // PDH label
                if pd_show_labels or pd_show_prices
                    _p = array.get(pdh_arr, k)
                    _x = position_labels == 'Left' ? array.get(arr_time, k) : array.get(arr_time, k + 1)
                    _t = pd_label_text('PH', _p, pd_show_labels, pd_show_prices)
                    if _t != ''
                        array.push(labels, label.new(x = _x, y = _p, xloc  = xloc.bar_time, text  = _t, textcolor = session_high_color,style = label.style_none, color = #00000000))

                // horizontal segment for PDL between CPR period k start/end
                if not na(array.get(pdl_arr, k))
                    line_pdL = line.new(x1 = array.get(arr_time, k),y1 = array.get(pdl_arr, k),x2 = array.get(arr_time, k + 1),y2 = array.get(pdl_arr, k),xloc = xloc.bar_time,color = session_low_color,width= line_width,style= pd_style)
                    array.push(lines, line_pdL)

                // PDL label
                if pd_show_labels or pd_show_prices
                    _p = array.get(pdl_arr, k)
                    _x = position_labels == 'Left' ? array.get(arr_time, k) : array.get(arr_time, k + 1)
                    _t = pd_label_text('PL', _p, pd_show_labels, pd_show_prices)
                    if _t != ''
                        array.push(labels, label.new(x  = _x, y  = _p, xloc = xloc.bar_time, text  = _t, textcolor = session_low_color, style = label.style_none, color = #00000000))


isHoliday(_date) =>
    is_holiday = _date == timestamp(2024, 12, 25, 15, 30) or _date == timestamp(2025, 02, 26, 15, 30) or _date == timestamp(2025, 03, 14, 15, 30) or _date == timestamp(2025, 03, 31, 15, 30) or _date == timestamp(2025, 04, 10, 15, 30) or _date == timestamp(2025, 04, 14, 15, 30) or _date == timestamp(2025, 04, 18, 15, 30) or _date == timestamp(2025, 05, 01, 15, 30) or _date == timestamp(2025, 08, 15, 15, 30) or _date == timestamp(2025, 08, 27, 15, 30) or _date == timestamp(2025, 10, 02, 15, 30) or _date == timestamp(2025, 10, 21, 15, 30) or _date == timestamp(2025, 10, 22, 15, 30) or _date == timestamp(2025, 11, 05, 15, 30) or _date == timestamp(2025, 12, 25, 15, 30)
    is_holiday

getDevEndTime() =>
    ONE_DAY = 1000 * 60 * 60 * 24
    var dev_end_time = 0
    if resolution == 'D'
        dev_end_time := time_close(resolution) + ONE_DAY
        dev_end_time
    else if resolution == 'W'
        dev_end_time := time_close(resolution) + ONE_DAY * 7
        dev_end_time
    else if resolution == 'M'
        dev_end_time := time_close(resolution) + ONE_DAY * 30
        dev_end_time
    else if resolution == '6M'
        dev_end_time := time_close(resolution) + ONE_DAY * 30 * 6
        dev_end_time
    else
        dev_end_time := time_close(resolution) + ONE_DAY * 30 * 12
        dev_end_time

    while dayofweek(dev_end_time) == dayofweek.saturday or dayofweek(dev_end_time) == dayofweek.sunday or check_holidays and isHoliday(dev_end_time)
        dev_end_time := dev_end_time + ONE_DAY
        dev_end_time

    if extend_dev_cpr_line
        dev_end_time := dev_end_time + ONE_DAY * dev_cpr_line_days
        dev_end_time

    dev_end_time

drawLineAndLabel(_price, _line_color, _text, _text_color, is_dev = false) =>
    labelText = _text
    if is_dev
        if _text == 'Dev R1'
            labelText := 'Dev R1'
        else if _text == 'Dev S1'
            labelText := 'Dev S1'
        else if _text == 'Dev CPR'
            labelText := 'Dev CPR'

    _showLbl = true
    _showPrc = true
    if is_dev
        if _text == 'Dev CPR'
            _showLbl := dev_cpr_show_labels
            _showPrc := dev_cpr_show_prices
        else if _text == 'Dev R1'
            _showLbl := dev_r1_show_labels
            _showPrc := dev_r1_show_prices
        else if _text == 'Dev S1'
            _showLbl := dev_s1_show_labels
            _showPrc := dev_s1_show_prices
        else
            _showLbl := dev_cpr_show_labels
            _showPrc := dev_cpr_show_prices

    start_time = time_close(resolution)
    end_time   = is_dev ? getDevEndTime() : time_close(resolution)

    _aLine = line.new(x1 = start_time, y1 = _price, x2 = end_time, y2 = _price,
                      xloc = xloc.bar_time, color = _line_color, width = line_width)
    line.delete(_aLine[1])

    if _showLbl or _showPrc
        var string display = ''
        if is_dev and _text == 'Dev R1' and _showPrc
            pct    = (_price - close) / close * 100
            pctStr = str.tostring(pct, '#.0')
            if _showLbl
                display := str.format('                                {0} - {1} ({2}%)',
                                      labelText, math.round_to_mintick(_price), pctStr)
            else
                display := str.format('                                {0} ({1}%)',
                                      math.round_to_mintick(_price), pctStr)
        else
            if labelText == ''
                if _showPrc
                    display := str.format('                                {0}', math.round_to_mintick(_price))
            else
                if _showLbl and _showPrc
                    display := str.format('                                {0} - {1}',
                                          labelText, math.round_to_mintick(_price))
                else if _showLbl
                    display := '                                ' + labelText
                else if _showPrc
                    display := str.format('                                {0}', math.round_to_mintick(_price))
        if display != ''
            label.new(x = end_time, y = _price, xloc = xloc.bar_time,
                      text = display, textcolor = _line_color, style = label.style_none)

    _aLine

[curr_h, curr_l, curr_c] = request.security(syminfo.tickerid, resolution, [high, low, close], lookahead = barmerge.lookahead_on)

if barstate.islast
    dpp = (curr_h + curr_l + curr_c) / 3.0
    dbc = (curr_h + curr_l) / 2.0
    dtc = dpp * 2 - dbc
    dev_top = dtc > dbc ? dtc : dbc
    dev_bot = dbc < dtc ? dbc : dtc

    if dev_cpr_show
        dtp = drawLineAndLabel(dev_top, dev_cpr_color, '', dev_cpr_color, true)
        drawLineAndLabel(dpp, dev_cpr_color, 'Dev CPR', dev_cpr_color, true)
        dbp = drawLineAndLabel(dev_bot, dev_cpr_color, '', dev_cpr_color, true)
        linefill.new(dtp, dbp, color.new(dev_cpr_color, 70))

    if dev_r1_show
        _dev_r1 = dpp * 2 - curr_l
        if kind == FIBONACCI
            _dev_r1 := dpp + 0.382 * (curr_h - curr_l)
            _dev_r1
        drawLineAndLabel(_dev_r1, dev_r1_color, 'Dev R1', dev_r1_color, true)

    if dev_s1_show
        _dev_s1 = dpp * 2 - curr_h
        if kind == FIBONACCI
            _dev_s1 := dpp - 0.382 * (curr_h - curr_l)
            _dev_s1
        drawLineAndLabel(_dev_s1, dev_s1_color, 'Dev S1', dev_s1_color, true)

// Functions
getAllTimeHigh() =>
    h = 0.0
    h := bar_index == 0 ? high : high > h[1] ? high : h[1]
    h

getAllTimeLow() =>
    l = 0.0
    l := bar_index == 0 ? low : low < l[1] ? low : l[1]
    l

get_resolution() =>
    resolution = 'M'
    if timeframe.isintraday
        resolution := timeframe.multiplier <= 15 ? 'D' : 'W'
        resolution
    else if timeframe.isweekly or timeframe.ismonthly
        resolution := '12M'
        resolution
    resolution

// Session line drawer (no extend)
drawLine(price, _text, lineColor, lineStyle, showLabels, showPrices) =>
    fLineStyle = switch lineStyle
        'Dotted' => line.style_dotted
        'Dashed' => line.style_dashed
        => line.style_solid
    endOfDay = time_tradingday + 105000000
    aLine = line.new(x1 = time_tradingday, y1 = price, x2 = endOfDay, y2 = price, xloc = xloc.bar_time, color = lineColor, style = fLineStyle)
    line.delete(aLine[1])
    fText = _text
    if showLabels and showPrices
        fText := str.format('{0} - {1}', _text, math.round_to_mintick(price))
    else if showPrices
        fText := str.format('{0}', math.round_to_mintick(price))
    if showLabels or showPrices
        aLabel = label.new(endOfDay, price, xloc=xloc.bar_time,
                           text=str.format('                                {0}', fText),
                           textcolor=lineColor, style=label.style_none)
        label.delete(aLabel[1])

drawOpen(show, resolution, labelText, lineColor, lineStyle, showLabels, showPrices) =>
    _open = request.security(syminfo.tickerid, resolution, open)
    if show
        drawLine(_open, labelText, lineColor, lineStyle, showLabels, showPrices)

drawHighLow(show, resolution, labelTextHigh, labelTextLow, highColor, lowColor, lineStyle, showLabels, showPrices) =>
    [_high, _low] = request.security(syminfo.tickerid, resolution, [high[1], low[1]])
    if show and not na(_high)
        drawLine(_high, labelTextHigh, highColor, lineStyle, showLabels, showPrices)
        drawLine(_low,  labelTextLow,  lowColor,  lineStyle, showLabels, showPrices)

// Session Open
drawOpen(show_day_open, 'D', '     Day Open', session_open_color, session_open_line_style, true, true)


// ──────────────────────────────────────────────────────────────────────────────
// Moving Average
// ──────────────────────────────────────────────────────────────────────────────
ma(source, length, type) =>
    type == "SMA" ? ta.sma(source, length) :
     type == "EMA" ? ta.ema(source, length) :
     type == "SMMA (RMA)" ? ta.rma(source, length) :
     type == "WMA" ? ta.wma(source, length) :
     type == "VWMA" ? ta.vwma(source, length) :
     na

show_ma1   = input(false   , "MA №1", inline="MA #1", group = 'Moving Averages')
ma1_type   = input.string("EMA"  , ""     , inline="MA #1", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = 'Moving Averages')
ma1_source = input(close  , ""     , inline="MA #1", group = 'Moving Averages')
ma1_length = input.int(8     , ""     , inline="MA #1", minval=1, group = 'Moving Averages')
ma1_color  = input(color.new(color.fuchsia, 0), ""     , inline="MA #1", group = 'Moving Averages')
ma1 = ma(ma1_source, ma1_length, ma1_type)
plot(show_ma1 ? ma1 : na, color = ma1_color, title="MA №1", display=display.all-display.status_line)

show_ma2   = input(false   , "MA №2", inline="MA #2", group = 'Moving Averages')
ma2_type   = input.string("EMA"  , ""     , inline="MA #2", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = 'Moving Averages')
ma2_source = input(close  , ""     , inline="MA #2", group = 'Moving Averages')
ma2_length = input.int(13     , ""     , inline="MA #2", minval=1, group = 'Moving Averages')
ma2_color  = input(color.new(color.orange, 0), ""     , inline="MA #2", group = 'Moving Averages')
ma2 = ma(ma2_source, ma2_length, ma2_type)
plot(show_ma2 ? ma2 : na, color = ma2_color, title="MA №2", display=display.all-display.status_line)


show_ma3   = input(false   , "MA №3", inline="MA #3", group = 'Moving Averages')
ma3_type   = input.string("EMA"  , ""     , inline="MA #3", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = 'Moving Averages')
ma3_source = input(close  , ""     , inline="MA #3", group = 'Moving Averages')
ma3_length = input.int(34    , ""     , inline="MA #3", minval=1, group = 'Moving Averages')
ma3_color  = input(color.new(color.green, 0), ""     , inline="MA #3", group = 'Moving Averages')
ma3 = ma(ma3_source, ma3_length, ma3_type)
plot(show_ma3 ? ma3 : na, color = ma3_color, title="MA №3", display=display.all-display.status_line)


show_ma4   = input(false   , "MA №4", inline="MA #4", group = 'Moving Averages')
ma4_type   = input.string("EMA"  , ""     , inline="MA #4", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = 'Moving Averages')
ma4_source = input(close  , ""     , inline="MA #4", group = 'Moving Averages')
ma4_length = input.int(21    , ""     , inline="MA #4", minval=1, group = 'Moving Averages')
ma4_color  = input(color.new(color.red, 0), ""     , inline="MA #4", group = 'Moving Averages')
ma4 = ma(ma4_source, ma4_length, ma4_type)
plot(show_ma4 ? ma4 : na, color = ma4_color, title="MA №4", display=display.all-display.status_line)


show_ma5   = input(false   , "MA №5", inline="MA #5", group = 'Moving Averages')
ma5_type   = input.string("EMA"  , ""     , inline="MA #5", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = 'Moving Averages')
ma5_source = input(close  , ""     , inline="MA #5", group = 'Moving Averages')
ma5_length = input.int(55    , ""     , inline="MA #5", minval=1, group = 'Moving Averages')
ma5_color  = input(color.new(color.navy, 0), ""     , inline="MA #5", group = 'Moving Averages')
ma5 = ma(ma5_source, ma5_length, ma5_type)
plot(show_ma5 ? ma5 : na, color = ma5_color, title="MA №5", display=display.all-display.status_line)


// ──────────────────────────────────────────────────────────────────────────────
// Day-Open Anchored VWAP (resets at each trading day's open)
// ──────────────────────────────────────────────────────────────────────────────
group_dvwap = 'Day-Open Anchored VWAP'

dvwap_show         = input.bool(false,               'Show Day-Open VWAP',         group = group_dvwap)
dvwap_history_mode = input.string('Only Today',       'History Mode',               options = ['All Days', 'Only Today'], group = group_dvwap,
                                  tooltip = 'All Days: plots VWAP for every trading day.\nOnly Today: draws VWAP only for the current session.')
show_only_today    = dvwap_history_mode == 'Only Today'

dvwap_src          = input.source(hlc3,             'Price (VWAP source)',        group = group_dvwap)
dvwap_col_above    = input.color(color.new(color.teal,   0), 'Color when price ≥ VWAP', group = group_dvwap)
dvwap_col_below    = input.color(color.new(color.purple, 0), 'Color when price < VWAP',  group = group_dvwap)
dvwap_width        = input.int(2,                   'Line width',                 minval = 1, maxval = 5, group = group_dvwap)
dvwap_show_label   = input.bool(true,               'Show VWAP Label',            group = group_dvwap)
dvwap_mark_anchor  = input.bool(true,               'Mark Day Open (anchor)',     group = group_dvwap)

is_intraday = timeframe.isintraday

// Detect start of new trading day
new_day = na(time_tradingday[1]) or (time_tradingday != time_tradingday[1])

// Reset cumulative sums each new day
var float _pv_sum = na
var float _v_sum  = na
if is_intraday
    if new_day or na(_pv_sum) or na(_v_sum)
        _pv_sum := dvwap_src * volume
        _v_sum  := volume
    else
        _pv_sum += dvwap_src * volume
        _v_sum  += volume

day_open_vwap = is_intraday and _v_sum > 0 ? _pv_sum / _v_sum : na
dv_col        = close >= day_open_vwap ? dvwap_col_above : dvwap_col_below

// ── GLOBAL-SCOPE PLOTS ──
plot(dvwap_show and is_intraday and not show_only_today ? day_open_vwap : na,
     title = 'Day-Open VWAP (All Days)', color = dv_col, linewidth = dvwap_width, display=display.all-display.status_line)

// Anchor marker for "All Days"
plotshape(dvwap_mark_anchor and dvwap_show and is_intraday and new_day and not show_only_today,
          title = 'Day-Open VWAP Anchor',
          style = shape.triangleup, location = location.belowbar,
          size = size.tiny, color = color.new(dv_col, 0), display=display.all-display.status_line)

// ── ONLY-TODAY VWAP LINES ──
var line[] dv_lines = array.new_line()
if show_only_today and dvwap_show and is_intraday
    if new_day and array.size(dv_lines) > 0
        for i = 0 to array.size(dv_lines) - 1
            line.delete(array.get(dv_lines, i))
        array.clear(dv_lines)

    is_same_session_as_prev = not new_day
    if is_same_session_as_prev and not na(day_open_vwap) and not na(day_open_vwap[1])
        l = line.new(x1 = time[1], y1 = day_open_vwap[1],
                     x2 = time,   y2 = day_open_vwap,
                     xloc = xloc.bar_time, extend = extend.none,
                     color = dv_col, width = dvwap_width)
        array.push(dv_lines, l)

// ── LABELS ──
var label dvwap_lbl = na
if barstate.islast and dvwap_show and dvwap_show_label and is_intraday and not na(day_open_vwap)
    label.delete(dvwap_lbl)
    rounded_vwap = math.ceil(day_open_vwap / syminfo.mintick) * syminfo.mintick
    dvwap_lbl := label.new(x = time, y = day_open_vwap, xloc = xloc.bar_time,
                           text = str.format('                                VWAP AA - {0}', rounded_vwap),
                           textcolor = dv_col, style = label.style_none, color = color.new(color.black, 100))

// For "Only Today", mark today's anchor with a small ▲ label
var label dvwap_anchor_lbl = na
if dvwap_mark_anchor and show_only_today and dvwap_show and is_intraday and new_day
    label.delete(dvwap_anchor_lbl)
    dvwap_anchor_lbl := label.new(x = time, y = low, xloc = xloc.bar_time,
                                  text = '▲', textcolor = dv_col, style = label.style_label_up,
                                  color = color.new(color.black, 100))


// ──────────────────────────────────────────────────────────────────────────────
// Initial Balance (IB) + Custom Sessions
// ──────────────────────────────────────────────────────────────────────────────
group_ib = 'Initial Balance (IB)'

// — Controls —
ib_show                = input.bool(false,  'Show IB',                             group = group_ib)
ib_last_n              = input.int(1,      'Display Last N IBs',                  minval = 1, group = group_ib,tooltip = 'Default 1 = only the latest IB')
ib_auto                = input.bool(true,  'Auto (first hour from session open)', group = group_ib, inline = 'ib0',tooltip = 'Auto = 60 minutes from the sessionʼs first bar')
ib_session             = input.session('0915-1015', 'Custom IB Session',          group = group_ib, inline = 'ib0',tooltip = 'Used only when Auto is OFF (e.g., 0915-1015 for NSE)')
ib_line_style_choice   = input.string('Dashed', 'Line Style', options=['Solid','Dashed','Dotted'], group = group_ib)
ib_line_width          = input.int(2, 'Line Width', minval=1, maxval=5, group = group_ib)
ib_top_color           = input.color(color.new(#089981, 0), 'IB High / Top Color',   group = group_ib)
ib_bottom_color        = input.color(color.new(#F23645, 0), 'IB Low / Bottom Color', group = group_ib)
ib_fill_transp         = input.int(80, 'Box Fill Transparency', minval=0, maxval=100, group = group_ib)

// — Line visibility options —
ib_show_lines          = input.bool(false,  'Show IB Lines', group = group_ib, inline='lines')
ib_show_top_line       = input.bool(true,  'Top',           group = group_ib, inline='lines')
ib_show_bottom_line    = input.bool(true,  'Bottom',        group = group_ib, inline='lines')

ib_linestyle(_s) =>
    _s == 'Solid'  ? line.style_solid : _s == 'Dashed' ? line.style_dashed : line.style_dotted

_ib_new_day = na(time_tradingday[1]) or time_tradingday != time_tradingday[1]


var int _ib_auto_start = na
if _ib_new_day
    _ib_auto_start := time

_ib_auto_end = _ib_auto_start + 60 * 60 * 1000

_ib_inside_auto    = time >= _ib_auto_start and time < _ib_auto_end
_ib_inside_custom  = not na(time(timeframe.period, ib_session))
_ib_inside_ib      = ib_auto ? _ib_inside_auto : _ib_inside_custom

_ib_start_today    = _ib_inside_ib and not _ib_inside_ib[1]

type _IBRec
    int   start_t
    int   end_t
    int   last_t
    float top
    float bot
    box   ib_box
    line  line_top
    line  line_bot

var _IBRec[] _ib_list = array.new<_IBRec>()


if _ib_start_today
    array.push(_ib_list, _IBRec.new(time, time, time, high, low, na, na, na))


if array.size(_ib_list) > 0
    _ib = array.get(_ib_list, array.size(_ib_list) - 1)
    _ib.last_t := time
    if _ib_inside_ib
        _ib.end_t := time
        _ib.top   := math.max(_ib.top, high)
        _ib.bot   := math.min(_ib.bot, low)

if array.size(_ib_list) > ib_last_n
    _old = array.get(_ib_list, 0)
    if not na(_old.ib_box)
        box.delete(_old.ib_box)
    if not na(_old.line_top)
        line.delete(_old.line_top)
    if not na(_old.line_bot)
        line.delete(_old.line_bot)
    array.shift(_ib_list)


if ib_show and array.size(_ib_list) > 0 and barstate.islastconfirmedhistory
    ls = ib_linestyle(ib_line_style_choice)
    for i = 0 to array.size(_ib_list) - 1
        r = array.get(_ib_list, i)

        if not na(r.ib_box)
            box.delete(r.ib_box)
        if not na(r.line_top)
            line.delete(r.line_top)
        if not na(r.line_bot)
            line.delete(r.line_bot)

        r.ib_box := box.new(left   = r.start_t,top    = r.top,right  = r.end_t,bottom = r.bot,xloc   = xloc.bar_time,border_color = color.new(color.silver, 90),bgcolor      = color.new(color.silver, ib_fill_transp))

        if ib_show_lines and ib_show_top_line
            r.line_top := line.new(x1 = r.start_t, y1 = r.top, x2 = r.last_t, y2 = r.top,xloc = xloc.bar_time, color = ib_top_color, width = ib_line_width, style = ls)

        if ib_show_lines and ib_show_bottom_line
            r.line_bot := line.new(x1 = r.start_t, y1 = r.bot, x2 = r.last_t, y2 = r.bot,xloc = xloc.bar_time, color = ib_bottom_color, width = ib_line_width, style = ls)

        array.set(_ib_list, i, r)

// ──────────────────────────────────────────────────────────────────────────────
// Range (bar High–Low)
// ──────────────────────────────────────────────────────────────────────────────

string r_grp = 'Range (Bar Range)'

r_showOnCandles = input.bool(false, 'Show Range on Candles', group = r_grp)

r_toggleDark   = input.bool(false,   title='Dark Mode',  group=r_grp)
r_displayMode  = input.string('Number', 'Display As', options=['Number','Percentage'], group=r_grp)
r_threshold    = input.float(100.0,  title='Threshold', minval=0.0, step=0.1, group=r_grp)
r_textColor    = r_toggleDark ? color.white : color.black

r_rangeSize    = high - low
r_rangePct     = r_rangeSize * 100.0 / close

r_roundedSize  = math.round(r_rangeSize)
r_roundedPct   = math.round(r_rangePct * 10.0) / 10.0

r_overThresh   = (r_displayMode == 'Number'     and r_rangeSize > r_threshold) or
                 (r_displayMode == 'Percentage' and r_rangePct  > r_threshold)

r_txt          = r_displayMode == 'Number'
                 ? str.tostring(r_roundedSize)
                 : str.tostring(r_roundedPct) + '%'

var float t_range_pts = na
t_range_pts := math.round_to_mintick(high - low)
t_range_text = na(t_range_pts) ? "—" : str.tostring(t_range_pts)

if r_showOnCandles and r_overThresh
    r_isBull = close > open
    r_yPos   = r_isBull ? high : low
    r_yLoc   = r_isBull ? yloc.abovebar : yloc.belowbar

    label.new(
      x         = bar_index,
      y         = r_yPos,
      xloc      = xloc.bar_index,
      yloc      = r_yLoc,
      text      = r_txt,
      style     = label.style_none,
      color     = color.new(color.black, 100),
      textcolor = r_textColor,
      size      = size.small)


// ──────────────────────────────────────────────────────────────────────────────
// VOLUME — Calculations only (plots are in the companion Volume sub-pane script)
// Vol vs MA % is used in the info table below
// ──────────────────────────────────────────────────────────────────────────────
string vol_grp    = 'Volume Indicator'
vol_ma_length     = input.int(20,     'Volume MA Length',   minval = 1, maxval = 200, group = vol_grp)
vol_ma_type       = input.string('SMA', 'Volume MA Type',   options = ['SMA', 'EMA'], group = vol_grp)
vol_ob_mult       = input.float(1.5,  'High Volume Multiplier (for alert)', minval = 1.0, step = 0.1, group = vol_grp)

vol_ma_val     = vol_ma_type == 'SMA' ? ta.sma(volume, vol_ma_length) : ta.ema(volume, vol_ma_length)
vol_rel_pct    = (volume - vol_ma_val) / vol_ma_val * 100
vol_rel_text   = str.format("{0}%", str.tostring(math.round(vol_rel_pct), "#"))
vol_rel_color  = volume >= vol_ma_val ? color.new(color.green, 0) : color.new(color.red, 0)


// ──────────────────────────────────────────────────────────────────────────────
// CONSOLIDATION ZONES (ported from LonesomeTheBlue, converted to v6)
// ──────────────────────────────────────────────────────────────────────────────
string cz_grp = 'Consolidation Zones'

cz_show      = input.bool(true,  'Show Consolidation Zones', group = cz_grp)
cz_prd       = input.int(10,     'Lookback Period',          minval = 2, maxval = 50,  group = cz_grp)
cz_conslen   = input.int(5,      'Min Consolidation Length', minval = 2, maxval = 20,  group = cz_grp)
cz_paintcons = input.bool(true,  'Paint Consolidation Area', group = cz_grp)
cz_zonecol   = input.color(color.new(color.blue, 70), 'Zone Color', group = cz_grp)
cz_res_col   = input.color(color.new(color.red,  70), 'Resistance Line Color', group = cz_grp)
cz_sup_col   = input.color(color.new(color.lime, 70), 'Support Line Color',    group = cz_grp)

// Zigzag pivot detection
float cz_hb_ = ta.highestbars(cz_prd) == 0 ? high : na
float cz_lb_ = ta.lowestbars(cz_prd)  == 0 ? low  : na

var int   cz_dir = 0
float     cz_zz  = na
float     cz_pp  = na

cz_dir := not na(cz_hb_) and na(cz_lb_) ? 1 : not na(cz_lb_) and na(cz_hb_) ? -1 : cz_dir

if not na(cz_hb_) and not na(cz_lb_)
    cz_zz := cz_dir == 1 ? cz_hb_ : cz_lb_
else
    cz_zz := not na(cz_hb_) ? cz_hb_ : not na(cz_lb_) ? cz_lb_ : na

// Walk back to find the dominant pivot
for x = 0 to 1000
    if na(close[x]) or cz_dir != cz_dir[x]
        break
    if not na(cz_zz[x])
        if na(cz_pp)
            cz_pp := cz_zz[x]
        else
            if cz_dir[x] == 1 and cz_zz[x] > cz_pp
                cz_pp := cz_zz[x]
            if cz_dir[x] == -1 and cz_zz[x] < cz_pp
                cz_pp := cz_zz[x]

var int   cz_conscnt  = 0
var float cz_condhigh = na
var float cz_condlow  = na
float     cz_H_       = ta.highest(cz_conslen)
float     cz_L_       = ta.lowest(cz_conslen)
var line  cz_upline   = na
var line  cz_dnline   = na
bool      cz_brkup    = false
bool      cz_brkdn    = false

if ta.change(cz_pp) != 0
    if cz_conscnt > cz_conslen
        if cz_pp > cz_condhigh
            cz_brkup := true
        if cz_pp < cz_condlow
            cz_brkdn := true
    if cz_conscnt > 0 and cz_pp <= cz_condhigh and cz_pp >= cz_condlow
        cz_conscnt += 1
    else
        cz_conscnt := 0
else
    cz_conscnt += 1

if cz_show and cz_conscnt >= cz_conslen
    if cz_conscnt == cz_conslen
        cz_condhigh := cz_H_
        cz_condlow  := cz_L_
    else
        line.delete(cz_upline)
        line.delete(cz_dnline)
        cz_condhigh := math.max(cz_condhigh, high)
        cz_condlow  := math.min(cz_condlow,  low)

    cz_upline := line.new(bar_index, cz_condhigh, bar_index - cz_conscnt, cz_condhigh,
                          color = cz_res_col, style = line.style_dashed, width = 1)
    cz_dnline := line.new(bar_index, cz_condlow,  bar_index - cz_conscnt, cz_condlow,
                          color = cz_sup_col, style = line.style_dashed, width = 1)

// Consolidation zone fill
cz_ph = plot(cz_show ? cz_condhigh : na, color = na, style = plot.style_stepline, title = 'CZ High')
cz_pl = plot(cz_show ? cz_condlow  : na, color = na, style = plot.style_stepline, title = 'CZ Low')
fill(cz_ph, cz_pl,
     color = cz_paintcons and cz_conscnt > cz_conslen ? cz_zonecol : color.new(color.white, 100),
     title = 'Consolidation Zone Fill')



//====================================================================
// CPR Table (uses Daily CPR math + pair bias header)
//====================================================================

// User-defined colors & theme
string t_GRP_TABLE   = '════════ Table Options ═════════'
t_toggleDarkColors   = input.bool(false, title = 'Dark Mode', group = t_GRP_TABLE)

// Choose whether bias is based on current chart symbol or NIFTY–BANKNIFTY pair
string t_biasMode = input.string('Current', 'Bias Mode', group   = t_GRP_TABLE, options = ['Current', 'Pairs'])


t_FrameCol  = t_toggleDarkColors ? color.new(#999999, 50) : color.rgb(241, 241, 241)
t_BorderCol = t_toggleDarkColors ? color.new(#999999, 50) : color.rgb(241, 241, 241)
t_TextColor = t_toggleDarkColors ? color.new(color.white, 0) : color.new(color.black, 0)
t_BGColor   = t_toggleDarkColors ? color.new(color.black, 100)   : color.new(color.white, 100)

// Table size and position options
string t_tablesize = input.string('small', 'Size', inline = 't_tblsz', group = t_GRP_TABLE, options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'])
string t_tableposY = input.string('middle', '↕',    inline = 't_tblsz', group = t_GRP_TABLE, options = ['top', 'middle', 'bottom'])
string t_tableposX = input.string('right',  '↔',    inline = 't_tblsz', group = t_GRP_TABLE, options = ['left', 'center', 'right'])

// 1) Pivot resolutions
t_resDaily   = 'D'
t_resWeekly  = 'W'
t_resMonthly = 'M'

// 2) Helper: compute classic-CPR bounds (BC, TC) and pivot from prior-bar of a given resolution
t_getBounds(res, h, l, c) =>
    t_pivot = (h + l + c) / 3.0
    t_bc    = (h + l) / 2.0
    t_tc    = 2.0 * t_pivot - t_bc
    [t_bc, t_tc, t_pivot]

// 3a) Daily CPR bounds (yesterday, day-before, two-days-ago)
[t_ph1, t_pl1, t_pc1] = request.security(syminfo.tickerid, t_resDaily,  [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[t_ph2, t_pl2, t_pc2] = request.security(syminfo.tickerid, t_resDaily,  [high[2], low[2], close[2]], lookahead = barmerge.lookahead_on)
[t_ph3, t_pl3, t_pc3] = request.security(syminfo.tickerid, t_resDaily,  [high[3], low[3], close[3]], lookahead = barmerge.lookahead_on)

[t_bc1, t_tc1, t_pivot1] = t_getBounds(t_resDaily,  t_ph1, t_pl1, t_pc1)
[t_bc2, t_tc2, t_pivot2] = t_getBounds(t_resDaily,  t_ph2, t_pl2, t_pc2)
[t_bc3, t_tc3, t_pivot3] = t_getBounds(t_resDaily,  t_ph3, t_pl3, t_pc3)

// 3b) Weekly CPR bounds
[t_phW, t_plW, t_pcW]    = request.security(syminfo.tickerid, t_resWeekly,  [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[t_bcW, t_tcW, t_pivotW] = t_getBounds(t_resWeekly,  t_phW, t_plW, t_pcW)

// 3c) Monthly CPR bounds
[t_phM, t_plM, t_pcM]    = request.security(syminfo.tickerid, t_resMonthly, [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[t_bcM, t_tcM, t_pivotM] = t_getBounds(t_resMonthly, t_phM, t_plM, t_pcM)

// 4) Compute "location" for Monthly, Weekly, Daily (price vs CPR bounds)
t_calcLoc(res, bc, tc) =>
    t_lower = math.min(bc, tc)
    t_upper = math.max(bc, tc)
    t_c     = request.security(syminfo.tickerid, res, close, lookahead = barmerge.lookahead_on)
    t_c > t_upper ? 'Above' : t_c < t_lower ? 'Below' : 'Inside'

t_locM = t_calcLoc(t_resMonthly, t_bcM, t_tcM)
t_locW = t_calcLoc(t_resWeekly,  t_bcW, t_tcW)
t_locD = t_calcLoc(t_resDaily,   t_bc1, t_tc1)

// 5) CPR width (daily only)
t_cpr_width  = math.abs(t_tc1 - t_bc1) / t_pivot1 * 100
t_widthLabel = t_cpr_width <= 0.05 ? 'Super Narrow' :
               t_cpr_width > 0.05 and t_cpr_width < 0.13 ? 'Narrow' :
               t_cpr_width <= 0.3 ? 'Medium' : 'Wide'

// 6) CPR-type logic over last three daily CPRs (normalized band order)
t_l1 = math.min(t_bc1, t_tc1)
t_u1 = math.max(t_bc1, t_tc1)

t_l2 = math.min(t_bc2, t_tc2)
t_u2 = math.max(t_bc2, t_tc2)

t_l3 = math.min(t_bc3, t_tc3)
t_u3 = math.max(t_bc3, t_tc3)

t_isAsc    = t_l2 < t_l1 and t_u2 < t_u1 and t_l2 < t_u1
t_isDesc   = t_l2 > t_l1 and t_u2 > t_u1 and t_l2 > t_u1
t_isInside = t_l1 >= t_l2 and t_u1 <= t_u2
t_isOutside= t_l1 <= t_l2 and t_u1 >= t_u2
t_isAscRev = t_l3 < t_l2 and t_u3 < t_u2 and t_l2 > t_l1 and t_u2 > t_u1 and t_l2 > t_u2
t_isDrRev  = t_l3 > t_l2 and t_u3 > t_u2 and t_l2 < t_l1 and t_u2 < t_u1 and t_l2 < t_l1
t_isOverlap= not (t_isAsc or t_isDesc or t_isInside or t_isOutside or t_isAscRev or t_isDrRev)


t_typeLabel = t_isAscRev ? 'Asc Rev' :
              t_isDrRev  ? 'Desc Rev' :
              t_isAsc    ? 'Ascending' :
              t_isDesc   ? 'Descending' :
              t_isInside ? 'Inside' :
              t_isOutside? 'Outside' :
                           'Overlapping'

// 11) Open & Current location on intraday (uses first bar open of the day)
t_newDay = ta.change(time('D')) != 0
var float t_dayOpenPrice = na
if t_newDay
    t_dayOpenPrice := open

// Extra R3/S3/R4/S4 for 12-location scheme
t_r1 = 2 * t_pivot1 - t_pl1
t_s1 = 2 * t_pivot1 - t_ph1
t_r2 = t_pivot1 + (t_ph1 - t_pl1)
t_s2 = t_pivot1 - (t_ph1 - t_pl1)

t_r3 = t_pivot1 + 2 * (t_ph1 - t_pl1)
t_s3 = t_pivot1 - 2 * (t_ph1 - t_pl1)
t_r4 = t_pivot1 + 3 * (t_ph1 - t_pl1)
t_s4 = t_pivot1 - 3 * (t_ph1 - t_pl1)

t_lowerCPR = math.min(t_bc1, t_tc1)
t_upperCPR = math.max(t_bc1, t_tc1)

// Map a price to one of 12 labels
t_loc12(price, lowerCPR, upperCPR, r1_, r2_, r3_, r4_, s1_, s2_, s3_, s4_) =>
    price >= lowerCPR and price <= upperCPR ? "Inside CPR" :price > upperCPR ? (price <= r1_ ? "Between CPR & R1" :price <= r2_ ? "Beyond R1" :price <= r3_ ? "Beyond R2" :price <= r4_ ? "Beyond R3" : "Beyond R4") :(price >= s1_ ? "Between CPR & S1" :price >= s2_ ? "Beyond S1" :price >= s3_ ? "Beyond S2" :price >= s4_ ? "Beyond S3" : "Beyond S4")

t_openLoc    = na(t_dayOpenPrice) ? "—" : t_loc12(t_dayOpenPrice, t_lowerCPR, t_upperCPR, t_r1, t_r2, t_r3, t_r4, t_s1, t_s2, t_s3, t_s4)
t_currentLoc = t_loc12(close,      t_lowerCPR, t_upperCPR, t_r1, t_r2, t_r3, t_r4, t_s1, t_s2, t_s3, t_s4)

// Color mapper for the 12-location scheme
t_locColor12(lbl) =>
    lbl == "Inside CPR"? color.blue :lbl == "Between CPR & R1"  ? color.blue :lbl == "Between CPR & S1"  ? color.blue :lbl == "Beyond R1"?  color.rgb(0,170,  0) :lbl == "Beyond R2"?  color.rgb(0,200,  0) :lbl == "Beyond R3"?  color.rgb(0,230,  0) :lbl == "Beyond R4"?  color.rgb(0,255,  0) :lbl == "Beyond S1"?  color.rgb(200,  0,  0) :lbl == "Beyond S2"?  color.rgb(220,  0,  0) :lbl == "Beyond S3"?  color.rgb(240,  0,  0) :color.rgb(255,  0,  0)

t_openCol = na(t_dayOpenPrice) ? color.gray : t_locColor12(t_openLoc)
t_currCol = t_locColor12(t_currentLoc)

// ── IB Metrics for Table (uses the IB module's latest record) ──
var float t_ib_points = na
var float t_ib_pct    = na
if array.size(_ib_list) > 0
    _lastIB = array.get(_ib_list, array.size(_ib_list) - 1)
    t_ib_points := math.round(_lastIB.top - _lastIB.bot)
    t_ib_pct    := t_ib_points / close * 100.0


//====================================================================
// NIFTY & BANKNIFTY CPR Pair Bias (your working code, embedded)
//====================================================================

// Symbols
symbolNifty     = "NSE:NIFTY1!"
symbolBankNifty = "NSE:BANKNIFTY1!"

// CPR function (previous day HLC, Daily CPR)
f_cpr(sym) =>
    dh = request.security(sym, "D", high[1],  lookahead = barmerge.lookahead_off)
    dl = request.security(sym, "D", low[1],   lookahead = barmerge.lookahead_off)
    dc = request.security(sym, "D", close[1], lookahead = barmerge.lookahead_off)

    pp = (dh + dl + dc) / 3.0
    bc = (dh + dl) / 2.0
    tc = 2.0 * pp - bc
    [pp, bc, tc]

// Location of price vs CPR:  1 = Above, -1 = Below, 0 = Inside
f_loc(price, bc, tc) =>
    upper = math.max(bc, tc)
    lower = math.min(bc, tc)

    isAbove = price > upper
    isBelow = price < lower

    isAbove ? 1 : isBelow ? -1 : 0

// CPR + price for both indices
[ppN, bcN, tcN] = f_cpr(symbolNifty)
[ppB, bcB, tcB] = f_cpr(symbolBankNifty)

// Price on current chart timeframe
closeN = request.security(symbolNifty,     timeframe.period, close, lookahead = barmerge.lookahead_off)
closeB = request.security(symbolBankNifty, timeframe.period, close, lookahead = barmerge.lookahead_off)

// Locations: 1 = above, -1 = below, 0 = inside
locN = f_loc(closeN, bcN, tcN)
locB = f_loc(closeB, bcB, tcB)

// Booleans
niftyAboveCPR     = locN ==  1
niftyBelowCPR     = locN == -1
bankniftyAboveCPR = locB ==  1
bankniftyBelowCPR = locB == -1

// Overall Bias Logic
bothAbove = niftyAboveCPR and bankniftyAboveCPR
bothBelow = niftyBelowCPR and bankniftyBelowCPR

biasText  = bothAbove ? "BULLS" : bothBelow ? "BEARS" : "PATIENCE"
biasColor = bothAbove ? color.new(color.green,  0) :bothBelow ? color.new(color.red,   0) :color.new(color.gray,0)

// --- trade bias modes ---
t_tradeBias_curr  = t_locD == 'Above' ? 'Bulls' : t_locD == 'Below' ? 'Bears' : 'Patience'
t_tradeBias_pairs = bothAbove ? 'Bulls' : bothBelow ? 'Bears' : 'Patience'
t_tradeBias       = t_biasMode == 'Current' ? t_tradeBias_curr : t_tradeBias_pairs
t_tradeBiasCol    = t_tradeBias == 'Bulls' ? color.green : t_tradeBias == 'Bears' ? color.red : color.gray


// Helper text / colors for table rows
f_loc_text(loc) =>
    loc ==  1 ? "Above CPR"  :loc == -1 ? "Below CPR"  :"Inside CPR"

f_loc_color(loc) =>
    loc ==  1 ? color.new(color.lime,  0) :loc == -1 ? color.new(color.red,   0) : color.new(color.orange,0)


// Build the table (2 × 20)
var table t_T = table.new(position = t_tableposY + '_' + t_tableposX,
                          columns = 2, rows = 20,
                          bgcolor = t_BGColor, frame_color = t_FrameCol, frame_width = 1,
                          border_color = t_BorderCol, border_width = 1)

if barstate.islast
    // Header: use pair bias (BULL/BEAR/NEUTRAL)
    table.merge_cells(t_T, 0, 0, 1, 0)
    table.cell(t_T, 0, 0, 'Trust the ' + t_tradeBias,
               bgcolor = t_tradeBiasCol, text_color = color.white,
               text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    // Monthly / Weekly / Daily
    table.cell(t_T, 0, 1, 'Monthly', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 1, t_locM, text_color = t_locM == 'Above' ? color.green : t_locM == 'Below' ? color.red : color.orange,
               text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    table.cell(t_T, 0, 2, 'Weekly', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 2, t_locW, text_color = t_locW == 'Above' ? color.green : t_locW == 'Below' ? color.red : t_locW == 'Inside' ? color.orange : color.gray,
               text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    table.cell(t_T, 0, 3, 'Daily', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 3, t_locD, text_color = t_locD == 'Above' ? color.green : t_locD == 'Below' ? color.red : color.orange,
               text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    // Open / Now
    table.cell(t_T, 0, 4, 'Open', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 4, t_openLoc, text_color = t_openCol, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    table.cell(t_T, 0, 5, 'Now', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 5, t_currentLoc, text_color = t_currCol, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    // Spacer row
    table.merge_cells(t_T, 0, 6, 1, 6)
    table.cell(t_T, 0, 6, '', bgcolor = color.new(t_tradeBiasCol, 50), text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)

    // CPR Width / Type
    table.cell(t_T, 0, 7,  'CPR Width', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 7,  t_widthLabel, text_color = t_TextColor, text_halign = text.align_center, text_size = t_tablesize)

    table.cell(t_T, 0, 8,  'CPR Type',  text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 8,  t_typeLabel, text_color = t_TextColor, text_halign = text.align_center, text_size = t_tablesize)

    // IB
    t_ib_text = na(t_ib_points) or na(t_ib_pct) ? "—" : str.format("{0} ({1}%)", t_ib_points, str.tostring(t_ib_pct, "#.0"))
    t_ib_col  = not na(t_ib_pct) and t_ib_pct > 0.6 ? color.red : color.green

    table.cell(t_T, 0, 9, "IB", text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 9, t_ib_text, text_color = t_ib_col, text_halign = text.align_center, text_size = t_tablesize)

    // Range row
    table.cell(t_T, 0, 10, 'Range', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 10, t_range_text, text_color = t_TextColor, text_halign = text.align_center, text_size = t_tablesize)

    // Volume row (new)
    table.cell(t_T, 0, 11, 'Vol vs MA', text_color = t_TextColor, text_halign = text.align_center, text_formatting = text.format_bold, text_size = t_tablesize)
    table.cell(t_T, 1, 11, vol_rel_text, text_color = vol_rel_color, text_halign = text.align_center, text_size = t_tablesize)


// ──────────────────────────────────────────────
// ALERTCONDITIONS – CPR LOCATION (M / W / D)
// ──────────────────────────────────────────────

// Monthly CPR
alertcondition(t_locM == 'Above',  title = 'Monthly CPR – Price Above',  message = 'Price is ABOVE the Monthly CPR')
alertcondition(t_locM == 'Below',  title = 'Monthly CPR – Price Below',  message = 'Price is BELOW the Monthly CPR')
alertcondition(t_locM == 'Inside', title = 'Monthly CPR – Price Inside', message = 'Price is INSIDE the Monthly CPR')

// Weekly CPR
alertcondition(t_locW == 'Above',  title = 'Weekly CPR – Price Above',  message = 'Price is ABOVE the Weekly CPR')
alertcondition(t_locW == 'Below',  title = 'Weekly CPR – Price Below',  message = 'Price is BELOW the Weekly CPR')
alertcondition(t_locW == 'Inside', title = 'Weekly CPR – Price Inside', message = 'Price is INSIDE the Weekly CPR')

// Daily CPR
alertcondition(t_locD == 'Above',  title = 'Daily CPR – Price Above',  message = 'Price is ABOVE the Daily CPR')
alertcondition(t_locD == 'Below',  title = 'Daily CPR – Price Below',  message = 'Price is BELOW the Daily CPR')
alertcondition(t_locD == 'Inside', title = 'Daily CPR – Price Inside', message = 'Price is INSIDE the Daily CPR')


// ──────────────────────────────────────────────
// ALERTCONDITIONS – CPR WIDTH (DAILY)
// ──────────────────────────────────────────────

alertcondition(t_widthLabel == 'Super Narrow', title = 'CPR Width – Super Narrow', message = 'Daily CPR width is SUPER NARROW')
alertcondition(t_widthLabel == 'Narrow',       title = 'CPR Width – Narrow',       message = 'Daily CPR width is NARROW')
alertcondition(t_widthLabel == 'Medium',       title = 'CPR Width – Medium',       message = 'Daily CPR width is MEDIUM')
alertcondition(t_widthLabel == 'Wide',         title = 'CPR Width – Wide',         message = 'Daily CPR width is WIDE')


// ──────────────────────────────────────────────
// ALERTCONDITIONS – CPR TYPE (BASED ON LAST 3 DAYS)
// ──────────────────────────────────────────────

alertcondition(t_typeLabel == 'Ascending',  title = 'CPR Type – Ascending',           message = 'Daily CPR type: ASCENDING')
alertcondition(t_typeLabel == 'Descending', title = 'CPR Type – Descending',          message = 'Daily CPR type: DESCENDING')
alertcondition(t_typeLabel == 'Inside',     title = 'CPR Type – Inside',              message = 'Daily CPR type: INSIDE CPR')
alertcondition(t_typeLabel == 'Outside',    title = 'CPR Type – Outside',             message = 'Daily CPR type: OUTSIDE CPR')
alertcondition(t_typeLabel == 'Asc Rev',    title = 'CPR Type – Ascending Reversal',  message = 'Daily CPR type: ASCENDING REVERSAL')
alertcondition(t_typeLabel == 'Desc Rev',   title = 'CPR Type – Descending Reversal', message = 'Daily CPR type: DESCENDING REVERSAL')
alertcondition(t_typeLabel == 'Overlapping',title = 'CPR Type – Overlapping',         message = 'Daily CPR type: OVERLAPPING')

// ──────────────────────────────────────────────
// ALERTCONDITIONS – VOLUME
// ──────────────────────────────────────────────

alertcondition(volume > vol_ma_val * vol_ob_mult, title = 'Volume – High Volume Bar', message = 'High volume bar detected (above MA multiplier threshold)')
alertcondition(volume > vol_ma_val,               title = 'Volume – Above MA',        message = 'Volume is above the Volume MA')
alertcondition(volume < vol_ma_val,               title = 'Volume – Below MA',        message = 'Volume is below the Volume MA')

// ──────────────────────────────────────────────
// ALERTCONDITIONS – CONSOLIDATION ZONES
// ──────────────────────────────────────────────
alertcondition(cz_brkup,  title = 'Consolidation – Breakout Up',   message = 'Price broke out ABOVE the consolidation zone')
alertcondition(cz_brkdn,  title = 'Consolidation – Breakout Down', message = 'Price broke out BELOW the consolidation zone')
````
