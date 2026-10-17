# SwiftTrend Structure

- url: https://www.tradingview.com/script/Ph3yy7MW-SwiftTrend-Structure/
- type: indicator
- pine_id: PUB;d9d18e1548844efe852b7e7ec086b0e7
- version: 1.0

## Description

█ OVERVIEW
SwiftTrend Structure is an extended version of the SwiftTrend indicator, designed to provide more reliable trend filtering.
The biggest enhancement over the original version is the introduction of dual trend confirmation. A price crossing of the SwiftTrend line alone is no longer sufficient to change the trend direction. Instead, the move must also be confirmed by a corresponding pivot breakout (BoS/ChoCh).
This approach significantly reduces false trend reversals during ranging markets and noisy price action.
Pivot breakout detection (BoS/ChoCh) is an integral part of the indicator's logic and serves as the confirmation mechanism for trend changes. At the same time, these breakout signals can also be used independently as trade signals based on market structure.
All features of the indicator are fully optional and can be enabled or disabled independently, allowing the tool to be used either as a clean trend filter or as a more comprehensive market structure analysis tool.

█ CONCEPTS
Traditional trend-following indicators often reverse too early during consolidations or too late after a new trend has already developed.
The original SwiftTrend determines trend direction solely by the relationship between price and its dynamic trend line.
SwiftTrend Structure extends this concept by incorporating market structure analysis.
A trend reversal is confirmed only when two conditions are met:
* price breaks the SwiftTrend line,
* the corresponding pivot breakout (BoS/ChoCh) occurs.
After price crosses the trend line, the indicator does not immediately change direction. Instead, it enters a pending state, waiting for additional confirmation.
The pending state ends in one of two ways:
* the required pivot breakout (BoS/ChoCh) confirms the trend reversal,
* or price returns back into the previous trend range, canceling the pending state and keeping the existing trend unchanged.
This mechanism filters out many temporary breaks of the trend line that would otherwise generate false trend reversals.
Besides confirming trend changes, the indicator simultaneously monitors pivot breakouts using two independent pivot lengths.
This allows traders to observe both short-term and longer-term market structure.
BoS/ChoCh signals can also be used independently from the trend confirmation logic, making the indicator useful for discretionary Price Action trading.

█ FEATURES
SwiftTrend
* Average Body Periods – period used to calculate the average candle body size
* Band Multiplier – width of the SwiftTrend band
* Tolerance Multiplier – additional margin used while waiting for trend confirmation
* Uptrend Color
* Downtrend Color
* Show Trend Line
* Fill Shade
* Color Bars
* Highlight Waiting State (bgcolor)

Signals
* Show BOS/ChoCh Signals – displays pivot breakout signals
* Show Only BOS/ChoCh Signals Aligned With Trend – filters signals according to the current trend
* Show Trend Change Labels – displays Buy/Sell labels after confirmed trend changes

BoS/ChoCh Confirmation
* Confirm Trend Change With Pivot Breakout – enables dual trend confirmation
* Pivot Length #1 – first pivot detection period
* Pivot Length #2 – second pivot detection period
* Show Broken Pivot Lines – displays broken pivot levels
* Pivot Line Transparency

Unbroken Pivot Lines
* Show Unbroken Pivot Lines – displays active unbroken pivot levels
* Unbroken Pivot Lines Transparency
* Unbroken Pivot Lines Style

TP/SL
* Show TP/SL Levels – displays entry, Stop Loss and Take Profit levels
* Use ATR × For SL Instead Of %
* ATR Period For TP/SL
* ATR Multiplier For SL
* Stop Loss %
* Risk/Reward Ratio For TP1
* Risk/Reward Ratio For TP2
* Risk/Reward Ratio For TP3

TP/SL Display
Independent visibility control for:
* SL
* TP1
* TP2
* TP3

█ APPLICATIONS
SwiftTrend Structure is designed primarily as a trend filter, rather than a standalone buy/sell signal generator.
Its primary purpose is to identify the market direction with the highest probability of continuation.
For example, if:
* a momentum indicator shows bullish pressure,
* SwiftTrend Structure confirms an uptrend,
* a bullish BoS signal appears,
* and there is no significant resistance above price,
a long position may be considered based on the confluence of multiple independent factors.
The same logic can be applied when looking for short opportunities.

Using two independent pivot lengths allows simultaneous analysis of both short-term and long-term market structure.

The built-in TP/SL module provides an immediate visual risk/reward framework, making trade planning faster and more consistent.

█ NOTES
* Dual trend confirmation significantly reduces false trend reversals, although it may also delay the detection of new trends. This is a deliberate trade-off between faster reactions and higher signal quality.
* Disabling pivot confirmation makes the indicator behave similarly to the original SwiftTrend.
* Every module of the indicator can be enabled or disabled independently.
* BoS/ChoCh signals can be used both as trend confirmation and as standalone market structure signals.
* Best results are achieved when combined with market structure analysis, support and resistance zones, momentum indicators, and additional confirmation tools.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('SwiftTrend Structure', overlay = true, max_lines_count = 500, max_labels_count = 500)

// INPUTS 
period = input.int(100, 'Average Body Periods', minval = 1, group = 'SwiftTrend')
bandMultiplier = input.float(2.5, 'Band Multiplier', step = 0.1, group = 'SwiftTrend')
toleranceMultiplier = input.float(2.5, 'Tolerance Multiplier', step = 0.1, group = 'SwiftTrend')
upColor = input.color(color.rgb(6, 162, 47), 'Uptrend Color', group = 'SwiftTrend')
downColor = input.color(color.rgb(207, 23, 23), 'Downtrend Color', group = 'SwiftTrend')
showLine = input.bool(true, 'Show Trend Line', group = 'SwiftTrend')
fillShade = input.bool(true, 'Fill Shade', group = 'SwiftTrend')
colorBars = input.bool(true, 'Color Bars', group = 'SwiftTrend')
showPending = input.bool(false, 'Highlight waiting state)', group = 'SwiftTrend')

// Signals
showBosSignals = input.bool(true, 'Show BOS/ChoCh Signals', group = 'Signals')
filterBosByTrend = input.bool(false, 'Show only BOS/ChoCh signals aligned with trend', group = 'Signals')
showTrendLabels = input.bool(true, 'Show trend change labels', group = 'Signals')

// BoS / ChoCh Confirmation 
usePivotConfirmation = input.bool(true, 'Confirm trend change with pivot breakout', group = 'BoS/ChoCh Confirmation')
bosLength1 = input.int(3, 'Pivot Length #1', minval = 1, group = 'BoS/ChoCh Confirmation')
bosLength2 = input.int(15, 'Pivot Length #2', minval = 1, group = 'BoS/ChoCh Confirmation')
showBosLines = input.bool(true, 'Show broken pivot lines', group = 'BoS/ChoCh Confirmation')
pivotLineTransparency = input.int(60, 'Pivot line transparency', minval = 0, maxval = 100, group = 'BoS/ChoCh Confirmation')

// Unbroken Pivot Lines 
showUnbrokenPivots = input.bool(false, 'Show unbroken pivot lines', group = 'Unbroken Pivot Lines')
unbrokenTransparency = input.int(70, 'Unbroken pivot lines transparency', minval = 0, maxval = 100, group = 'Unbroken Pivot Lines')
unbrokenStyle = input.string(line.style_solid, 'Unbroken pivot lines style', options = [line.style_solid, line.style_dashed, line.style_dotted], group = 'Unbroken Pivot Lines')

// TP/SL 
show_targets  = input.bool(true, 'Show TP/SL Levels', group = 'TP/SL',
     tooltip = 'Draws entry, stop-loss and take-profit levels after every confirmed signal (trend change and/or BOS/ChoCh — depending on what is enabled in the "Signals" section).')
use_atr_sl    = input.bool(true, 'Use ATR × for SL instead of %', group = 'TP/SL')
tp_atr_period = input.int(14, 'ATR Period for TP/SL', group = 'TP/SL', minval = 1)
sl_atr_mult   = input.float(1.5, 'ATR Multiplier for SL', group = 'TP/SL', step = 0.1)
sl_percent    = input.float(1.0, 'SL % from Entry', group = 'TP/SL', step = 0.1)
rr_tp1        = input.float(1.0, 'Risk-Reward Ratio for TP1', group = 'TP/SL', step = 0.1)
rr_tp2        = input.float(2.0, 'Risk-Reward Ratio for TP2', group = 'TP/SL', step = 0.1)
rr_tp3        = input.float(3.0, 'Risk-Reward Ratio for TP3', group = 'TP/SL', step = 0.1)

// TP/SL Display 
show_sl_level  = input.bool(true, 'Show SL Level', group = 'TP/SL Display')
show_tp1_level = input.bool(true, 'Show TP1 Level', group = 'TP/SL Display')
show_tp2_level = input.bool(true, 'Show TP2 Level', group = 'TP/SL Display')
show_tp3_level = input.bool(true, 'Show TP3 Level', group = 'TP/SL Display')


bos_up_color = color.green
bos_down_color = color.red
bos_label_offset = ta.atr(14) * 0.12
atr_val = ta.atr(tp_atr_period)

// BoS / ChoCh Engine 
var array<float> pending_high_vals_1 = array.new_float(0)
var array<int>   pending_high_times_1 = array.new_int(0)
var array<float> pending_low_vals_1  = array.new_float(0)
var array<int>   pending_low_times_1  = array.new_int(0)

var array<float> pending_high_vals_2 = array.new_float(0)
var array<int>   pending_high_times_2 = array.new_int(0)
var array<float> pending_low_vals_2  = array.new_float(0)
var array<int>   pending_low_times_2  = array.new_int(0)

var int last_breakout_dir_1 = 0
var int last_breakout_dir_2 = 0

// Arrays for storing unbroken pivot lines (shared for both lengths)
var array<line>  unbroken_high_lines  = array.new_line(0)
var array<float> unbroken_high_prices = array.new_float(0)
var array<line>  unbroken_low_lines   = array.new_line(0)
var array<float> unbroken_low_prices  = array.new_float(0)

// TP/SL STATE 
var int      tpsl_dir         = 0
var float    tpsl_sl          = na
var float    tpsl_extreme     = na
var line     tpsl_entry_ln    = na
var label    tpsl_entry_lb    = na
var line     tpsl_sl_ln       = na
var label    tpsl_sl_lb       = na
var line     tpsl_tp1_ln      = na
var label    tpsl_tp1_lb      = na
var line     tpsl_tp2_ln      = na
var label    tpsl_tp2_lb      = na
var line     tpsl_tp3_ln      = na
var label    tpsl_tp3_lb      = na
var line     tpsl_ext_ln      = na
var linefill tpsl_risk_fill   = na
var linefill tpsl_reward_fill = na
var int      tpsl_entry_bar   = na

f_processPivot(length, pending_high_vals, pending_high_times, pending_low_vals, pending_low_times) =>
    pivot_high = ta.pivothigh(high, length, length)
    pivot_low  = ta.pivotlow(low, length, length)

    if not na(pivot_high)
        array.push(pending_high_vals, pivot_high)
        array.push(pending_high_times, time[length])
        if showUnbrokenPivots
            l_ub_high = line.new(time[length], pivot_high, time, pivot_high, xloc = xloc.bar_time, extend = extend.right, color = color.new(bos_up_color, unbrokenTransparency), style = unbrokenStyle, width = 1)
            array.push(unbroken_high_lines, l_ub_high)
            array.push(unbroken_high_prices, pivot_high)

    if not na(pivot_low)
        array.push(pending_low_vals, pivot_low)
        array.push(pending_low_times, time[length])
        if showUnbrokenPivots
            l_ub_low = line.new(time[length], pivot_low, time, pivot_low, xloc = xloc.bar_time, extend = extend.right, color = color.new(bos_down_color, unbrokenTransparency), style = unbrokenStyle, width = 1)
            array.push(unbroken_low_lines, l_ub_low)
            array.push(unbroken_low_prices, pivot_low)

    bool bos_up   = false
    bool bos_down = false
    int  new_dir  = 0

    float broken_high_val  = na
    int   broken_high_time = na
    float broken_low_val   = na
    int   broken_low_time  = na

    
    if array.size(pending_high_vals) > 0
        for i = array.size(pending_high_vals) - 1 to 0
            level = array.get(pending_high_vals, i)
            bool crossed = close > level and close[1] <= level
            if crossed
                bos_up := true
                new_dir := 1
                broken_high_val := level
                broken_high_time := array.get(pending_high_times, i)
                if showBosLines
                    line.new(broken_high_time, level, time, level, xloc = xloc.bar_time, color = color.new(bos_up_color, pivotLineTransparency), width = 1)
                array.remove(pending_high_vals, i)
                array.remove(pending_high_times, i)

    if array.size(pending_low_vals) > 0
        for i = array.size(pending_low_vals) - 1 to 0
            level = array.get(pending_low_vals, i)
            bool crossed = close < level and close[1] >= level
            if crossed
                bos_down := true
                new_dir := -1
                broken_low_val := level
                broken_low_time := array.get(pending_low_times, i)
                if showBosLines
                    line.new(broken_low_time, level, time, level, xloc = xloc.bar_time, color = color.new(bos_down_color, pivotLineTransparency), width = 1)
                array.remove(pending_low_vals, i)
                array.remove(pending_low_times, i)

    [bos_up, bos_down, new_dir, broken_high_val, broken_high_time, broken_low_val, broken_low_time]

[bos_up_1, bos_down_1, new_dir_1, brk_high_1, brk_high_time_1, brk_low_1, brk_low_time_1] =
     f_processPivot(bosLength1, pending_high_vals_1, pending_high_times_1, pending_low_vals_1, pending_low_times_1)

[bos_up_2, bos_down_2, new_dir_2, brk_high_2, brk_high_time_2, brk_low_2, brk_low_time_2] =
     f_processPivot(bosLength2, pending_high_vals_2, pending_high_times_2, pending_low_vals_2, pending_low_times_2)

last_breakout_dir_1 := bos_up_1 or bos_down_1 ? new_dir_1 : last_breakout_dir_1
last_breakout_dir_2 := bos_up_2 or bos_down_2 ? new_dir_2 : last_breakout_dir_2

// Remove unbroken pivot lines when price breaks them
if showUnbrokenPivots
    if array.size(unbroken_high_lines) > 0
        for i = array.size(unbroken_high_lines) - 1 to 0
            if close > array.get(unbroken_high_prices, i)
                line.delete(array.get(unbroken_high_lines, i))
                array.remove(unbroken_high_lines, i)
                array.remove(unbroken_high_prices, i)

    if array.size(unbroken_low_lines) > 0
        for i = array.size(unbroken_low_lines) - 1 to 0
            if close < array.get(unbroken_low_prices, i)
                line.delete(array.get(unbroken_low_lines, i))
                array.remove(unbroken_low_lines, i)
                array.remove(unbroken_low_prices, i)


// SwiftTrend Engine 
body       = math.abs(open - close)
avgBody    = ta.sma(body, period)
bodyMid    = (open + close) / 2
basicUpper = bodyMid[1] + bandMultiplier * avgBody[1]
basicLower = bodyMid[1] - bandMultiplier * avgBody[1]
tolerance  = toleranceMultiplier * avgBody

var bool  isUptrend = true
var float avgLine   = na
var bool  pending   = false

if na(avgLine[1])
    avgLine   := basicLower
    isUptrend := true
else
    avgLine := isUptrend ? math.max(basicLower, nz(avgLine[1])) : math.min(basicUpper, nz(avgLine[1]))

marginLineBase = isUptrend ? avgLine - tolerance : avgLine + tolerance
bool rawBreak = isUptrend ? close < marginLineBase : close > marginLineBase

var bool trendChanged = false
trendChanged := false

bool confirmUpNow   = usePivotConfirmation ? (bos_up_1 or bos_up_2)   : false
bool confirmDownNow = usePivotConfirmation ? (bos_down_1 or bos_down_2) : false

if usePivotConfirmation
    if rawBreak
        pending := true
        if isUptrend and confirmDownNow
            isUptrend    := false
            trendChanged := true
            pending      := false
        else if not isUptrend and confirmUpNow
            isUptrend    := true
            trendChanged := true
            pending      := false
    else
        pending := false
else
    pending := false
    if rawBreak
        isUptrend    := not isUptrend
        trendChanged := true

// BOS SIGNALS 
bool showUp1   = showBosSignals and bos_up_1   and (not filterBosByTrend or isUptrend)
bool showDown1 = showBosSignals and bos_down_1 and (not filterBosByTrend or not isUptrend)
bool showUp2   = showBosSignals and bos_up_2   and (not filterBosByTrend or isUptrend)
bool showDown2 = showBosSignals and bos_down_2 and (not filterBosByTrend or not isUptrend)

plotshape(showUp1,   style = shape.triangleup,   location = location.belowbar, color = bos_up_color, size = size.tiny)
plotshape(showDown1, style = shape.triangledown, location = location.abovebar, color = bos_down_color, size = size.tiny)
plotshape(showUp2,   style = shape.triangleup,   location = location.belowbar, color = bos_up_color, size = size.tiny)
plotshape(showDown2, style = shape.triangledown, location = location.abovebar, color = bos_down_color, size = size.tiny)

plotLine = trendChanged ? na : marginLineBase

pLine   = plot(plotLine, color = showLine ? color.new(isUptrend ? upColor : downColor, 40) : na, linewidth = 2, style = plot.style_linebr, title = 'Trend Line')
pCenter = plot(hl2, display = display.none)

fill(pLine, pCenter, plotLine, hl2, 
     fillShade ? color.new(isUptrend ? upColor : downColor, 80) : na, 
     fillShade ? color.new(isUptrend ? upColor : downColor, 100) : na)

bgcolor(showPending and pending ? color.new(isUptrend ? downColor : upColor, 85) : na, 
        title = 'Waiting for BoS/ChoCh confirmation')

if trendChanged and showTrendLabels
    label.new(bar_index, 
              isUptrend ? low - tolerance * 0.5 : high + tolerance * 0.5, 
              isUptrend ? 'Buy' : 'Sell', 
              color = color.new(isUptrend ? upColor : downColor, 40), 
              style = isUptrend ? label.style_label_up : label.style_label_down, 
              textcolor = color.white, size = size.small)

// TP/SL TRIGGER LOGIC 
bool trend_buy_trigger  = showTrendLabels and trendChanged and isUptrend
bool trend_sell_trigger = showTrendLabels and trendChanged and not isUptrend
bool bos_buy_trigger    = showBosSignals and (showUp1 or showUp2)
bool bos_sell_trigger   = showBosSignals and (showDown1 or showDown2)

bool tpsl_trigger_buy  = trend_buy_trigger  or bos_buy_trigger
bool tpsl_trigger_sell = trend_sell_trigger or bos_sell_trigger

// TP/SL DRAWING AND STATE MANAGEMENT 

if show_targets and (tpsl_trigger_buy or tpsl_trigger_sell)

    bool is_buy_trade = not tpsl_trigger_sell

    line.delete(tpsl_entry_ln)
    label.delete(tpsl_entry_lb)
    line.delete(tpsl_sl_ln)
    label.delete(tpsl_sl_lb)
    line.delete(tpsl_tp1_ln)
    label.delete(tpsl_tp1_lb)
    line.delete(tpsl_tp2_ln)
    label.delete(tpsl_tp2_lb)
    line.delete(tpsl_tp3_ln)
    label.delete(tpsl_tp3_lb)
    line.delete(tpsl_ext_ln)
    linefill.delete(tpsl_risk_fill)
    linefill.delete(tpsl_reward_fill)

    tpsl_dir       := is_buy_trade ? 1 : -1
    tpsl_entry_bar := bar_index

    float entry_p   = close
    float risk_dist = use_atr_sl ? atr_val * sl_atr_mult : entry_p * (sl_percent / 100.0)

    color entry_col     = is_buy_trade ? upColor : downColor
    color sl_col        = color.new(downColor, 40)
    color tp_col        = color.new(upColor,  40)
    color risk_fill_c   = color.new(downColor, 70)
    color reward_fill_c = color.new(upColor,  70)

    float sl_p  = is_buy_trade ? entry_p - risk_dist : entry_p + risk_dist
    float tp1_p = is_buy_trade ? entry_p + risk_dist * rr_tp1 : entry_p - risk_dist * rr_tp1
    float tp2_p = is_buy_trade ? entry_p + risk_dist * rr_tp2 : entry_p - risk_dist * rr_tp2
    float tp3_p = is_buy_trade ? entry_p + risk_dist * rr_tp3 : entry_p - risk_dist * rr_tp3

    tpsl_sl      := sl_p
    tpsl_extreme := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

    tpsl_entry_ln := line.new(bar_index, entry_p, bar_index + 1, entry_p,
         color = entry_col, width = 2, extend = extend.none)
    tpsl_entry_lb := label.new(bar_index, entry_p,
         (is_buy_trade ? 'BUY ' : 'SELL ') + str.tostring(entry_p, format.mintick),
         style = label.style_label_left, color = entry_col,
         textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_sl_ln := line.new(bar_index, sl_p, bar_index + 1, sl_p,
             color = sl_col, width = 1, style = line.style_dashed, extend = extend.none)
        tpsl_sl_lb := label.new(bar_index, sl_p,
             'SL ' + str.tostring(sl_p, format.mintick),
             style = label.style_label_left, color = sl_col,
             textcolor = color.white, size = size.small)

    if show_tp1_level
        tpsl_tp1_ln := line.new(bar_index, tp1_p, bar_index + 1, tp1_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp1_lb := label.new(bar_index, tp1_p,
             'TP1 ' + str.tostring(tp1_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp2_level
        tpsl_tp2_ln := line.new(bar_index, tp2_p, bar_index + 1, tp2_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp2_lb := label.new(bar_index, tp2_p,
             'TP2 ' + str.tostring(tp2_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp3_level
        tpsl_tp3_ln := line.new(bar_index, tp3_p, bar_index + 1, tp3_p,
             color = tp_col, width = 1, style = line.style_dotted, extend = extend.none)
        tpsl_tp3_lb := label.new(bar_index, tp3_p,
             'TP3 ' + str.tostring(tp3_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_risk_fill := linefill.new(tpsl_entry_ln, tpsl_sl_ln, risk_fill_c)

    float fill_extreme = entry_p
    if is_buy_trade
        if show_tp1_level
            fill_extreme := math.max(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.max(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.max(fill_extreme, tp3_p)
        if fill_extreme > entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)
    else
        if show_tp1_level
            fill_extreme := math.min(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.min(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.min(fill_extreme, tp3_p)
        if fill_extreme < entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)

// TP/SL POSITION UPDATE 

if tpsl_dir != 0
    if not na(tpsl_entry_lb)
        label.set_x(tpsl_entry_lb, bar_index)
    if not na(tpsl_sl_lb)
        label.set_x(tpsl_sl_lb,    bar_index)
    if not na(tpsl_tp1_lb)
        label.set_x(tpsl_tp1_lb,   bar_index)
    if not na(tpsl_tp2_lb)
        label.set_x(tpsl_tp2_lb,   bar_index)
    if not na(tpsl_tp3_lb)
        label.set_x(tpsl_tp3_lb,   bar_index)

    if not na(tpsl_entry_ln)
        line.set_x2(tpsl_entry_ln, bar_index + 1)
    if not na(tpsl_sl_ln)
        line.set_x2(tpsl_sl_ln,    bar_index + 1)
    if not na(tpsl_tp1_ln)
        line.set_x2(tpsl_tp1_ln,   bar_index + 1)
    if not na(tpsl_tp2_ln)
        line.set_x2(tpsl_tp2_ln,   bar_index + 1)
    if not na(tpsl_tp3_ln)
        line.set_x2(tpsl_tp3_ln,   bar_index + 1)
    if not na(tpsl_ext_ln)
        line.set_x2(tpsl_ext_ln,   bar_index + 1)

    bool sl_hit = tpsl_dir == 1 ? low  <= tpsl_sl      : high >= tpsl_sl
    bool tp_hit = not na(tpsl_extreme) and
         (tpsl_dir == 1 ? high >= tpsl_extreme : low <= tpsl_extreme)

    if bar_index > tpsl_entry_bar and (sl_hit or tp_hit)
        if not na(tpsl_entry_ln)
            line.set_x2(tpsl_entry_ln, bar_index)
        if not na(tpsl_sl_ln)
            line.set_x2(tpsl_sl_ln,    bar_index)
        if not na(tpsl_tp1_ln)
            line.set_x2(tpsl_tp1_ln,   bar_index)
        if not na(tpsl_tp2_ln)
            line.set_x2(tpsl_tp2_ln,   bar_index)
        if not na(tpsl_tp3_ln)
            line.set_x2(tpsl_tp3_ln,   bar_index)
        if not na(tpsl_ext_ln)
            line.set_x2(tpsl_ext_ln,   bar_index)
        tpsl_dir := 0

barcolor(colorBars ? isUptrend ? upColor : downColor : na)

// ALERTS 
// Trend Change
alertcondition(trendChanged and isUptrend, 
     title   = "SwiftTrend: Trend → UP", 
     message = "Trend changed to UP — {{close}}")

alertcondition(trendChanged and not isUptrend, 
     title   = "SwiftTrend: Trend → DOWN", 
     message = "Trend changed to DOWN — {{close}}")

// BOS / ChoCh 
alertcondition(showUp1 or showUp2, 
     title   = "SwiftTrend: BOS/ChoCh UP", 
     message = "BOS/ChoCh UP — {{close}}")

alertcondition(showDown1 or showDown2, 
     title   = "SwiftTrend: BOS/ChoCh DOWN", 
     message = "BOS/ChoCh DOWN — {{close}}")
````
