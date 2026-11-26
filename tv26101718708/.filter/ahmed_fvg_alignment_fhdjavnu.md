# Ahmed FVG Alignment

- url: https://www.tradingview.com/script/FhdjAvnU-Ahmed-FVG-Alignment/
- type: indicator
- pine_id: PUB;ce5abccf6bed4484a73bb4a8034efa0c
- version: 1.0

## Description

This indicator scans multiple timeframes to detect Fair Value Gaps (FVG) and measure alignment across the market.

It tracks recent bullish and bearish FVG formations from lower to higher timeframes and calculates a live alignment score. The tool highlights when multiple timeframes are in agreement, helping traders identify high probability conditions.

The script also monitors the New York session kill zone (9:30 to 11:00 New York time), where volatility and trading opportunities are typically higher.

Main features:

* Multi timeframe FVG detection
* Bullish and bearish alignment scoring
* Simple sequence detection across 30s, 1m, and 3m
* Visual FVG zones on chart
* Dashboard showing real-time market state
* Alert conditions for strong alignment setups

This tool is designed for Nasdaq futures traders looking to align lower timeframe entries with higher timeframe direction.

## Source Code

````pine
//@version=5
indicator("Ahmed FVG Alignment", overlay=true, max_boxes_count=300, max_labels_count=100)
// Inputs
i_lookback   = input.int(5, "Recent FVG lookback", minval=1, maxval=30)
i_min_size   = input.float(2.0, "Minimum FVG size NQ points", minval=0, step=0.5)
i_thresh     = input.int(6, "Alert score threshold", minval=3, maxval=10)
i_show_boxes = input.bool(true, "Show FVG boxes")
i_show_dash  = input.bool(true, "Show dashboard")
i_kz_filter  = input.bool(true, "Only alert during NY kill zone")

// NY Kill Zone 9:30–11:00
ny_hour = hour(time, "America/New_York")
ny_min  = minute(time, "America/New_York")
ny_total = ny_hour * 60 + ny_min
in_kz = ny_total >= 570 and ny_total < 660

bgcolor(in_kz ? color.new(color.yellow, 92) : na)

// FVG functions
f_bull_since(tf) =>
    request.security(syminfo.tickerid, tf,
         ta.barssince(low > high[2] and (low - high[2]) >= i_min_size),
         lookahead=barmerge.lookahead_off)

f_bear_since(tf) =>
    request.security(syminfo.tickerid, tf,
         ta.barssince(high < low[2] and (low[2] - high) >= i_min_size),
         lookahead=barmerge.lookahead_off)

// Bars since FVG
bs_bull_30s = f_bull_since("30S")
bs_bull_1m  = f_bull_since("1")
bs_bull_3m  = f_bull_since("3")
bs_bull_5m  = f_bull_since("5")
bs_bull_15m = f_bull_since("15")
bs_bull_30m = f_bull_since("30")
bs_bull_1h  = f_bull_since("60")
bs_bull_4h  = f_bull_since("240")
bs_bull_1d  = f_bull_since("D")
bs_bull_1w  = f_bull_since("W")

bs_bear_30s = f_bear_since("30S")
bs_bear_1m  = f_bear_since("1")
bs_bear_3m  = f_bear_since("3")
bs_bear_5m  = f_bear_since("5")
bs_bear_15m = f_bear_since("15")
bs_bear_30m = f_bear_since("30")
bs_bear_1h  = f_bear_since("60")
bs_bear_4h  = f_bear_since("240")
bs_bear_1d  = f_bear_since("D")
bs_bear_1w  = f_bear_since("W")

// Active FVGs
bull_30s = not na(bs_bull_30s) and bs_bull_30s <= i_lookback
bull_1m  = not na(bs_bull_1m)  and bs_bull_1m  <= i_lookback
bull_3m  = not na(bs_bull_3m)  and bs_bull_3m  <= i_lookback
bull_5m  = not na(bs_bull_5m)  and bs_bull_5m  <= i_lookback
bull_15m = not na(bs_bull_15m) and bs_bull_15m <= i_lookback
bull_30m = not na(bs_bull_30m) and bs_bull_30m <= i_lookback
bull_1h  = not na(bs_bull_1h)  and bs_bull_1h  <= i_lookback
bull_4h  = not na(bs_bull_4h)  and bs_bull_4h  <= i_lookback
bull_1d  = not na(bs_bull_1d)  and bs_bull_1d  <= i_lookback
bull_1w  = not na(bs_bull_1w)  and bs_bull_1w  <= i_lookback

bear_30s = not na(bs_bear_30s) and bs_bear_30s <= i_lookback
bear_1m  = not na(bs_bear_1m)  and bs_bear_1m  <= i_lookback
bear_3m  = not na(bs_bear_3m)  and bs_bear_3m  <= i_lookback
bear_5m  = not na(bs_bear_5m)  and bs_bear_5m  <= i_lookback
bear_15m = not na(bs_bear_15m) and bs_bear_15m <= i_lookback
bear_30m = not na(bs_bear_30m) and bs_bear_30m <= i_lookback
bear_1h  = not na(bs_bear_1h)  and bs_bear_1h  <= i_lookback
bear_4h  = not na(bs_bear_4h)  and bs_bear_4h  <= i_lookback
bear_1d  = not na(bs_bear_1d)  and bs_bear_1d  <= i_lookback
bear_1w  = not na(bs_bear_1w)  and bs_bear_1w  <= i_lookback

// Scores
bull_score = (bull_30s?1:0)+(bull_1m?1:0)+(bull_3m?1:0)+(bull_5m?1:0)+(bull_15m?1:0)+(bull_30m?1:0)+(bull_1h?1:0)+(bull_4h?1:0)+(bull_1d?1:0)+(bull_1w?1:0)
bear_score = (bear_30s?1:0)+(bear_1m?1:0)+(bear_3m?1:0)+(bear_5m?1:0)+(bear_15m?1:0)+(bear_30m?1:0)+(bear_1h?1:0)+(bear_4h?1:0)+(bear_1d?1:0)+(bear_1w?1:0)

max_score = math.max(bull_score, bear_score)
bias_bull = bull_score > bear_score

// Simple sequence
bull_seq = bull_30s and bull_1m and bull_3m
bear_seq = bear_30s and bear_1m and bear_3m
seq_active = bull_seq or bear_seq

// Draw current TF FVG boxes
if i_show_boxes
    if low > high[2] and (low - high[2]) >= i_min_size
        box.new(bar_index - 2, low, bar_index + 30, high[2],
             bgcolor=color.new(color.lime, 82),
             border_color=color.new(color.lime, 20))
        label.new(bar_index, low, "Bull FVG", style=label.style_label_up, color=color.new(color.lime, 20), textcolor=color.white)

    if high < low[2] and (low[2] - high) >= i_min_size
        box.new(bar_index - 2, low[2], bar_index + 30, high,
             bgcolor=color.new(color.red, 82),
             border_color=color.new(color.red, 20))
        label.new(bar_index, high, "Bear FVG", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white)

// Signal labels
kz_ok = not i_kz_filter or in_kz
a_grade_bull = kz_ok and bull_seq and bull_score >= i_thresh and bull_score > bear_score
a_grade_bear = kz_ok and bear_seq and bear_score >= i_thresh and bear_score > bull_score

if a_grade_bull and not a_grade_bull[1]
    label.new(bar_index, low, "A-GRADE BULL\nScore: " + str.tostring(bull_score) + "/10", style=label.style_label_up, color=color.lime, textcolor=color.white)

if a_grade_bear and not a_grade_bear[1]
    label.new(bar_index, high, "A-GRADE BEAR\nScore: " + str.tostring(bear_score) + "/10", style=label.style_label_down, color=color.red, textcolor=color.white)

// Dashboard
var table dash = table.new(position.top_right, 4, 6, bgcolor=color.new(color.black, 10), border_width=1)

if i_show_dash and barstate.islast
    table.cell(dash, 0, 0, "Ahmed FVG", text_color=color.white)
    table.cell(dash, 1, 0, "Bull", text_color=color.lime)
    table.cell(dash, 2, 0, "Bear", text_color=color.red)
    table.cell(dash, 3, 0, "Status", text_color=color.white)

    table.cell(dash, 0, 1, "Score", text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(bull_score) + "/10", text_color=color.lime)
    table.cell(dash, 2, 1, str.tostring(bear_score) + "/10", text_color=color.red)
    table.cell(dash, 3, 1, max_score >= i_thresh ? "HOT" : "WAIT", text_color=max_score >= i_thresh ? color.yellow : color.gray)

    table.cell(dash, 0, 2, "30s/1m/3m", text_color=color.white)
    table.cell(dash, 1, 2, bull_seq ? "YES" : "NO", text_color=bull_seq ? color.lime : color.gray)
    table.cell(dash, 2, 2, bear_seq ? "YES" : "NO", text_color=bear_seq ? color.red : color.gray)
    table.cell(dash, 3, 2, seq_active ? "SEQ ACTIVE" : "NO SEQ", text_color=seq_active ? color.yellow : color.gray)

    table.cell(dash, 0, 3, "Kill Zone", text_color=color.white)
    table.cell(dash, 1, 3, in_kz ? "ACTIVE" : "OFF", text_color=in_kz ? color.yellow : color.gray)
    table.cell(dash, 2, 3, "NY", text_color=color.white)
    table.cell(dash, 3, 3, "9:30-11", text_color=color.white)

    table.cell(dash, 0, 4, "Signal", text_color=color.white)
    sig = a_grade_bull ? "BUY WATCH" : a_grade_bear ? "SELL WATCH" : "WAIT"
    sig_col = a_grade_bull ? color.lime : a_grade_bear ? color.red : color.gray
    table.cell(dash, 1, 4, sig, text_color=sig_col)
    table.cell(dash, 2, 4, "", text_color=color.white)
    table.cell(dash, 3, 4, max_score >= i_thresh ? "READY" : "NO", text_color=sig_col)

// Alerts
alertcondition(a_grade_bull, title="A-GRADE BULL FVG", message="A-GRADE BULL FVG setup detected. Wait for 3m FVG return entry.")
alertcondition(a_grade_bear, title="A-GRADE BEAR FVG", message="A-GRADE BEAR FVG setup detected. Wait for 3m FVG return entry.")
alertcondition(max_score[1] >= i_thresh and max_score < i_thresh, title="FVG Alignment Fading", message="FVG alignment score dropped below threshold.")
````
