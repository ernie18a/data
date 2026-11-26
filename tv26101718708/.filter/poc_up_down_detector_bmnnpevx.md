# POC up & down Detector

- url: https://www.tradingview.com/script/bmnnpEvx-POC-up-down-Detector/
- type: indicator
- pine_id: PUB;bb7755ebe4974e7f9a43bce170526b73
- version: 1.0

## Description

Consecutive POC Detector

The Consecutive POC Detector is a market structure and volume-based indicator that tracks the evolution of daily Point of Control (POC) levels to identify bullish, bearish, neutral, and potential ranging conditions.

Instead of relying on price action alone, the indicator analyzes how volume is distributed throughout the trading day and compares consecutive daily POC levels to determine whether market participation is shifting higher or lower.

Features

• Daily Point of Control calculation using intraday volume data.

• Multiple POC calculation methods:

Weighted OHLC
Range Overlap
HLC3
Close Price

• Automatic market state detection:

Bullish
Bearish
Neutral
Possible Ranging

• Dynamic POC levels plotted directly on the chart.

• High-volume confirmation system using relative volume analysis.

• Long and Short trade signals generated when price interacts with the previous day's POC under favorable market conditions.

• Strong Buy and Strong Sell confirmations after initial signal generation.

• Optional session filtering for futures, forex, and custom trading sessions.

Signal Logic

Bullish signals occur when:

Market state is Bullish.
Price trades below the previous POC.
Price closes back above the POC.
Volume exceeds the configured volume threshold.

Bearish signals occur when:

Market state is Bearish.
Price trades above the previous POC.
Price closes back below the POC.
Volume exceeds the configured volume threshold.

Additional Strong Buy and Strong Sell signals are generated when momentum confirms the original setup.

Dashboard Information

The built-in information panel displays:

Current market state
Previous POC
Yesterday's POC
Today's developing POC
Volume versus average volume
Above/Below POC interaction status
Best Used For
Index Futures
Crypto Markets
Forex
Stocks
Intraday Trading
Swing Trading

The indicator is designed to help traders identify volume-supported directional bias and potential institutional accumulation or distribution zones using consecutive Point of Control analysis.

## Source Code

````pine
//@version=6
indicator("Consecutive POC Detector", overlay=true, max_bars_back=1000, max_labels_count=500, max_lines_count=50)

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------
i_bins      = input.int(50, "Volume Profile Bins", minval=20, maxval=200)
i_tf        = input.timeframe("1", "Intraday TF", options=["1", "3", "5", "10", "15", "30"])
i_method    = input.string("Weighted OHLC", "POC Method", options=["Weighted OHLC", "Range Overlap", "HLC3", "Close"])
i_bodyMult  = input.float(3.0, "Body Weight vs Wicks", minval=1.0, maxval=10.0, step=0.25)

i_useSess   = input.bool(false, "Use Session Filter")
i_session   = input.session("0000-2359", "Profile Session")

i_lineWidth = input.int(2, "Line Width", minval=1, maxval=4)
i_volMult   = input.float(2.0, "Volume Multiplier", minval=0.5, step=0.5)

i_bullColor = input.color(color.new(color.lime, 0), "Bullish Color")
i_bearColor = input.color(color.new(color.red, 0), "Bearish Color")
i_neutColor = input.color(color.new(color.gray, 0), "Neutral Color")
i_rangColor = input.color(color.new(color.yellow, 0), "Ranging Color")

// -----------------------------------------------------------------------------
// LOWER TIMEFRAME DATA
// -----------------------------------------------------------------------------
intra_open = request.security_lower_tf(syminfo.tickerid, i_tf, open, ignore_invalid_timeframe=true)
intra_high = request.security_lower_tf(syminfo.tickerid, i_tf, high, ignore_invalid_timeframe=true)
intra_low  = request.security_lower_tf(syminfo.tickerid, i_tf, low, ignore_invalid_timeframe=true)
intra_close = request.security_lower_tf(syminfo.tickerid, i_tf, close, ignore_invalid_timeframe=true)
intra_vol  = request.security_lower_tf(syminfo.tickerid, i_tf, volume, ignore_invalid_timeframe=true)
intra_sess = request.security_lower_tf(syminfo.tickerid, i_tf, not na(time(timeframe.period, i_session)) ? 1.0 : 0.0, ignore_invalid_timeframe=true)

in_session_now = not na(time(timeframe.period, i_session))
in_session_prev = bar_index > 0 ? in_session_now[1] : false

new_calendar_day = timeframe.change("D")
new_session = in_session_now and not in_session_prev
new_profile = i_useSess ? (new_session or new_calendar_day) : new_calendar_day
chart_bar_allowed = not i_useSess or in_session_now

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
price_to_bin(price, day_low, bin_size, bins) =>
    int b = int(math.floor((price - day_low) / bin_size))
    int(math.max(0, math.min(bins - 1, b)))

add_segment(vol_bins, day_low, bin_size, bins, seg_low, seg_high, seg_vol) =>
    if not na(seg_low) and not na(seg_high) and not na(seg_vol) and seg_vol > 0
        float lo = math.min(seg_low, seg_high)
        float hi = math.max(seg_low, seg_high)

        if hi <= lo
            int b = price_to_bin(lo, day_low, bin_size, bins)
            array.set(vol_bins, b, array.get(vol_bins, b) + seg_vol)
        else
            int b0 = price_to_bin(lo, day_low, bin_size, bins)
            int b1 = price_to_bin(hi, day_low, bin_size, bins)

            for b = b0 to b1
                float row_lo = day_low + b * bin_size
                float row_hi = day_low + (b + 1) * bin_size
                float overlap = math.max(0.0, math.min(hi, row_hi) - math.max(lo, row_lo))

                if overlap > 0
                    float add_vol = seg_vol * overlap / (hi - lo)
                    array.set(vol_bins, b, array.get(vol_bins, b) + add_vol)
    0

// -----------------------------------------------------------------------------
// POC CALCULATION
// -----------------------------------------------------------------------------
calc_poc(open_arr, high_arr, low_arr, close_arr, vol_arr, bins, method, body_mult) =>
    int n = math.min(math.min(array.size(open_arr), array.size(high_arr)), math.min(math.min(array.size(low_arr), array.size(close_arr)), array.size(vol_arr)))

    if n == 0
        float(na)
    else
        float day_high = na
        float day_low = na

        for i = 0 to n - 1
            float h = array.get(high_arr, i)
            float l = array.get(low_arr, i)

            if not na(h) and not na(l)
                day_high := na(day_high) ? h : math.max(day_high, h)
                day_low := na(day_low) ? l : math.min(day_low, l)

        if na(day_high) or na(day_low) or day_high <= day_low
            float(na)
        else
            float bin_size = (day_high - day_low) / bins
            vol_bins = array.new_float(bins, 0.0)

            float total_vol = 0.0
            float vwap_sum = 0.0

            for i = 0 to n - 1
                float o = array.get(open_arr, i)
                float h = array.get(high_arr, i)
                float l = array.get(low_arr, i)
                float c = array.get(close_arr, i)
                float v = array.get(vol_arr, i)

                if not na(o) and not na(h) and not na(l) and not na(c) and not na(v) and v > 0
                    float bar_high = math.max(h, l)
                    float bar_low = math.min(h, l)
                    total_vol += v
                    vwap_sum += c * v

                    if method == "Close"
                        int b = price_to_bin(c, day_low, bin_size, bins)
                        array.set(vol_bins, b, array.get(vol_bins, b) + v)

                    else if method == "HLC3"
                        float p = (h + l + c) / 3.0
                        int b = price_to_bin(p, day_low, bin_size, bins)
                        array.set(vol_bins, b, array.get(vol_bins, b) + v)

                    else if method == "Range Overlap"
                        add_segment(vol_bins, day_low, bin_size, bins, bar_low, bar_high, v)

                    else
                        float body_low = math.max(bar_low, math.min(o, c))
                        float body_high = math.min(bar_high, math.max(o, c))

                        float bottom_len = math.max(0.0, body_low - bar_low)
                        float body_len = math.max(0.0, body_high - body_low)
                        float top_len = math.max(0.0, bar_high - body_high)

                        float weighted_len = bottom_len + top_len + body_len * body_mult

                        if weighted_len <= 0
                            int b = price_to_bin(c, day_low, bin_size, bins)
                            array.set(vol_bins, b, array.get(vol_bins, b) + v)
                        else
                            if bottom_len > 0
                                add_segment(vol_bins, day_low, bin_size, bins, bar_low, body_low, v * bottom_len / weighted_len)

                            if body_len > 0
                                add_segment(vol_bins, day_low, bin_size, bins, body_low, body_high, v * body_len * body_mult / weighted_len)

                            if top_len > 0
                                add_segment(vol_bins, day_low, bin_size, bins, body_high, bar_high, v * top_len / weighted_len)

            if total_vol <= 0
                float(na)
            else
                float vwap = vwap_sum / total_vol
                float max_vol = na
                float best_dist = na
                int max_bin = 0

                for b = 0 to bins - 1
                    float bv = array.get(vol_bins, b)
                    float mid = day_low + (b + 0.5) * bin_size
                    float dist = math.abs(mid - vwap)

                    bool better = na(max_vol) or bv > max_vol
                    bool tied_better = not na(max_vol) and math.abs(bv - max_vol) <= math.max(max_vol * 0.000001, 0.0000001) and (na(best_dist) or dist < best_dist)

                    if better or tied_better
                        max_vol := bv
                        max_bin := b
                        best_dist := dist

                float poc_raw = day_low + (max_bin + 0.5) * bin_size
                math.round(poc_raw / syminfo.mintick) * syminfo.mintick

// -----------------------------------------------------------------------------
// DAILY PROFILE STORAGE
// -----------------------------------------------------------------------------
var day_open_arr = array.new_float()
var day_high_arr = array.new_float()
var day_low_arr = array.new_float()
var day_close_arr = array.new_float()
var day_vol_arr = array.new_float()

var float poc_current = na
var float poc_d0 = na
var float poc_d1 = na

bool new_confirmed_poc = false

if new_profile
    float finished_poc = calc_poc(day_open_arr, day_high_arr, day_low_arr, day_close_arr, day_vol_arr, i_bins, i_method, i_bodyMult)

    if not na(finished_poc)
        poc_d1 := poc_d0
        poc_d0 := finished_poc
        new_confirmed_poc := true

    array.clear(day_open_arr)
    array.clear(day_high_arr)
    array.clear(day_low_arr)
    array.clear(day_close_arr)
    array.clear(day_vol_arr)

int ltf_n = math.min(math.min(array.size(intra_open), array.size(intra_high)), math.min(math.min(array.size(intra_low), array.size(intra_close)), array.size(intra_vol)))

if ltf_n > 0
    for i = 0 to ltf_n - 1
        bool allowed = not i_useSess or (array.size(intra_sess) > i and array.get(intra_sess, i) > 0)

        if allowed
            float o = array.get(intra_open, i)
            float h = array.get(intra_high, i)
            float l = array.get(intra_low, i)
            float c = array.get(intra_close, i)
            float v = array.get(intra_vol, i)

            if not na(o) and not na(h) and not na(l) and not na(c) and not na(v) and v > 0
                array.push(day_open_arr, o)
                array.push(day_high_arr, h)
                array.push(day_low_arr, l)
                array.push(day_close_arr, c)
                array.push(day_vol_arr, v)
else if chart_bar_allowed and not na(volume) and volume > 0
    array.push(day_open_arr, open)
    array.push(day_high_arr, high)
    array.push(day_low_arr, low)
    array.push(day_close_arr, close)
    array.push(day_vol_arr, volume)

if barstate.islast
    poc_current := calc_poc(day_open_arr, day_high_arr, day_low_arr, day_close_arr, day_vol_arr, i_bins, i_method, i_bodyMult)

// -----------------------------------------------------------------------------
// STATE MACHINE
// -----------------------------------------------------------------------------
var int mkt_state = 0
var float neutral_poc = na
var int rang_dir = 0
var int rang_count = 0
var int prev_dir = 0
var int prev_trend = 0

if new_confirmed_poc and not na(poc_d0) and not na(poc_d1)
    bool poc_up = poc_d0 > poc_d1
    bool poc_down = poc_d0 < poc_d1

    if mkt_state == 1
        if poc_up
            mkt_state := 1
        else
            neutral_poc := poc_d0
            prev_trend := 1
            mkt_state := 0
            rang_dir := 0
            rang_count := 0

    else if mkt_state == -1
        if poc_down
            mkt_state := -1
        else
            neutral_poc := poc_d0
            prev_trend := -1
            mkt_state := 0
            rang_dir := 0
            rang_count := 0

    else if mkt_state == 0
        if na(neutral_poc)
            if poc_up and prev_dir == 1
                mkt_state := 1
            else if poc_down and prev_dir == -1
                mkt_state := -1
        else
            if poc_up
                if poc_d0 > neutral_poc
                    mkt_state := 1
                    neutral_poc := na
            else if poc_down
                if poc_d0 < neutral_poc
                    if prev_trend == 1
                        mkt_state := -1
                        neutral_poc := na
                    else
                        mkt_state := 2
                        rang_count := 1
                        rang_dir := -1

    else if mkt_state == 2
        int cur_dir = poc_up ? 1 : poc_down ? -1 : 0

        if cur_dir != 0 and cur_dir == rang_dir
            rang_count += 1

            if rang_count >= 2
                mkt_state := cur_dir == 1 ? 1 : -1
                neutral_poc := na
                rang_count := 0
                rang_dir := 0
        else
            rang_count := 1
            rang_dir := cur_dir

    prev_dir := poc_up ? 1 : poc_down ? -1 : 0

// -----------------------------------------------------------------------------
// LINE AND LABEL
// -----------------------------------------------------------------------------
line_col = mkt_state == 1 ? i_bullColor : mkt_state == -1 ? i_bearColor : mkt_state == 2 ? i_rangColor : i_neutColor
line_lbl = mkt_state == 1 ? " BULLISH " : mkt_state == -1 ? " BEARISH " : mkt_state == 2 ? " POSSIBLE RANGING " : " NEUTRAL "

var line active_line = na
var label active_label = na

if new_confirmed_poc and not na(poc_d0)
    if not na(active_line)
        line.delete(active_line)

    if not na(active_label)
        label.delete(active_label)

    active_line := line.new(bar_index, poc_d0, bar_index + 1, poc_d0, color=line_col, width=i_lineWidth, style=line.style_solid, extend=extend.right)
    active_label := label.new(bar_index, poc_d0, line_lbl + str.tostring(poc_d0, "#.####"), style=label.style_label_right, color=color.new(line_col, 10), textcolor=color.white, size=size.normal)

// -----------------------------------------------------------------------------
// INTRADAY VOLUME
// -----------------------------------------------------------------------------
var float day_vol_sum = 0.0
var int day_bar_count = 0

if new_calendar_day
    day_vol_sum := volume
    day_bar_count := 1
else
    day_vol_sum += volume
    day_bar_count += 1

day_vol_avg = day_bar_count > 1 ? day_vol_sum / day_bar_count : float(na)
high_vol = not na(day_vol_avg) and day_vol_avg > 0 and day_bar_count >= 3 and volume > day_vol_avg * i_volMult

// -----------------------------------------------------------------------------
// TOUCH LOGIC
// -----------------------------------------------------------------------------
var bool touched_above = false
var bool touched_below = false

if new_calendar_day
    touched_above := false
    touched_below := false

if not na(poc_d0)
    if high > poc_d0
        touched_above := true

    if low < poc_d0
        touched_below := true

// -----------------------------------------------------------------------------
// SIGNALS
// -----------------------------------------------------------------------------
var bool bear_fired = false
var bool bull_fired = false

if new_calendar_day
    bear_fired := false
    bull_fired := false

bear_signal_raw = mkt_state == -1 and touched_above and close < poc_d0 and high_vol
bull_signal_raw = mkt_state == 1 and touched_below and close > poc_d0 and high_vol

bear_signal = bear_signal_raw and not bear_fired
bull_signal = bull_signal_raw and not bull_fired

if bear_signal
    bear_fired := true

if bull_signal
    bull_fired := true

var bool waiting_strong_bear = false
var bool waiting_strong_bull = false

if new_calendar_day
    waiting_strong_bear := false
    waiting_strong_bull := false

if bear_signal
    waiting_strong_bear := true

if bull_signal
    waiting_strong_bull := true

strong_sell = waiting_strong_bear and not bear_signal and open > close and close < poc_d0
strong_buy = waiting_strong_bull and not bull_signal and open < close and close > poc_d0

if strong_sell
    waiting_strong_bear := false

if strong_buy
    waiting_strong_bull := false

// -----------------------------------------------------------------------------
// LABELS
// -----------------------------------------------------------------------------
vol_ratio = not na(day_vol_avg) and day_vol_avg > 0 ? math.round(volume / day_vol_avg, 1) : float(na)

if bear_signal
    label.new(bar_index, high, "SHORT\nPOC: " + str.tostring(poc_d0, "#.####") + "\nVol: " + str.tostring(vol_ratio, "#.#") + "x", style=label.style_label_down, color=color.new(i_bearColor, 5), textcolor=color.white, size=size.normal)

if bull_signal
    label.new(bar_index, low, "LONG\nPOC: " + str.tostring(poc_d0, "#.####") + "\nVol: " + str.tostring(vol_ratio, "#.#") + "x", style=label.style_label_up, color=color.new(i_bullColor, 5), textcolor=color.white, size=size.normal)

if strong_sell
    label.new(bar_index, high, "STRONG SELL", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.large)

if strong_buy
    label.new(bar_index, low, "STRONG BUY", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=size.large)

barcolor(bear_signal_raw ? color.new(i_bearColor, 50) : bull_signal_raw ? color.new(i_bullColor, 50) : na)

// -----------------------------------------------------------------------------
// INFO TABLE
// -----------------------------------------------------------------------------
var table tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    state_txt = mkt_state == 1 ? "BULLISH" : mkt_state == -1 ? "BEARISH" : mkt_state == 2 ? "RANGING" : "Neutral"
    state_col = mkt_state == 1 ? i_bullColor : mkt_state == -1 ? i_bearColor : mkt_state == 2 ? i_rangColor : color.gray
    vol_txt = not na(day_vol_avg) and day_vol_avg > 0 ? str.tostring(math.round(volume / day_vol_avg, 2)) + "x" : "-"

    table.cell(tbl, 0, 0, "POC Detector", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, state_txt, text_color=state_col, text_size=size.small)
    table.cell(tbl, 0, 1, "POC Previous", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, na(poc_d1) ? "-" : str.tostring(poc_d1, "#.####"), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 2, "POC Yesterday", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, na(poc_d0) ? "-" : str.tostring(poc_d0, "#.####"), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 3, "POC Today", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 3, na(poc_current) ? "-" : str.tostring(poc_current, "#.####"), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 4, "Vol vs Avg", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 4, vol_txt, text_color=high_vol ? color.orange : color.white, text_size=size.small)
    table.cell(tbl, 0, 5, "Above/Below", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 5, (touched_above ? "Above" : "-") + " / " + (touched_below ? "Below" : "-"), text_color=color.white, text_size=size.small)
````
