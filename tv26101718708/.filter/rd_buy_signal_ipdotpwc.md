# RD buy signal

- url: https://www.tradingview.com/script/iPdotPWC-RD-buy-signal/
- type: indicator
- pine_id: PUB;b619b1908a00491dbca6b936098f8759
- version: 1.0

## Description

This gives buy signals in bullish stocks when they come down for retracements. Pls not it works only if higher time frame is bullish.

## Source Code

````pine
//@version=6
indicator(title="MTF Buy Signal", shorttitle="RD buy", overlay=true)

// ═══════════════════════════════════════════════════════
//              INPUT SETTINGS
// ═══════════════════════════════════════════════════════

macd_fast      = input.int(12,  "MACD Fast Length",  group="Higher TF MACD")
macd_slow      = input.int(26,  "MACD Slow Length",  group="Higher TF MACD")
macd_signal    = input.int(9,   "MACD Signal Length", group="Higher TF MACD")

w_rsi_len      = input.int(14,  "RSI Length",        group="Higher TF RSI")
w_rsi_min      = input.float(45.0, "Min RSI Level",  group="Higher TF RSI")

bb_len         = input.int(20,  "BB Length",         group="Higher TF Bollinger Bands")
bb_mult        = input.float(2.0, "BB StdDev",       group="Higher TF Bollinger Bands")

h_rsi_len      = input.int(14,  "RSI Length",        group="Current TF RSI")
h_rsi_min      = input.float(35.0, "Min RSI Level",  group="Current TF RSI")

stoch_k_len    = input.int(14,  "%K Length",         group="Current TF Stochastic")
stoch_k_smooth = input.int(3,   "%K Smoothing",      group="Current TF Stochastic")
stoch_d_smooth = input.int(3,   "%D Smoothing",      group="Current TF Stochastic")
stoch_cross_level = input.float(40.0, "Crossover Must Be Below", group="Current TF Stochastic")

show_signals   = input.bool(true, "Show Buy Signals on Chart", group="Display")
show_labels    = input.bool(true, "Show Signal Labels",        group="Display")

// ═══════════════════════════════════════════════════════
//     DETERMINE HIGHER TIMEFRAME BASED ON CURRENT TF
// ═══════════════════════════════════════════════════════

// If chart is Daily → use Monthly as higher TF
// All other timeframes (1H, 4H, etc.) → use Weekly as higher TF
is_daily_tf  = timeframe.isdaily
higher_tf    = is_daily_tf ? "M" : "W"

// ═══════════════════════════════════════════════════════
//         HIGHER TF MACD
// ═══════════════════════════════════════════════════════

higher_macd_line() =>
    [ml, _, _h] = ta.macd(close, macd_fast, macd_slow, macd_signal)
    ml

htf_macd_line      = request.security(syminfo.tickerid, higher_tf, higher_macd_line(),    lookahead=barmerge.lookahead_off)
htf_macd_line_prev = request.security(syminfo.tickerid, higher_tf, higher_macd_line()[1], lookahead=barmerge.lookahead_off)

cond_htf_macd_slope = htf_macd_line > htf_macd_line_prev

// ═══════════════════════════════════════════════════════
//         HIGHER TF RSI
// ═══════════════════════════════════════════════════════

htf_rsi = request.security(syminfo.tickerid, higher_tf, ta.rsi(close, w_rsi_len), lookahead=barmerge.lookahead_off)

cond_htf_rsi = htf_rsi >= w_rsi_min

// ═══════════════════════════════════════════════════════
//         HIGHER TF BOLLINGER BANDS
// ═══════════════════════════════════════════════════════

htf_bb_mid = request.security(syminfo.tickerid, higher_tf, ta.sma(close, bb_len), lookahead=barmerge.lookahead_off)
htf_close  = request.security(syminfo.tickerid, higher_tf, close,                  lookahead=barmerge.lookahead_off)

cond_htf_bb_upper_half = htf_close > htf_bb_mid

// ═══════════════════════════════════════════════════════
//         CURRENT TF RSI
// ═══════════════════════════════════════════════════════

curr_rsi = ta.rsi(close, h_rsi_len)

cond_curr_rsi = curr_rsi >= h_rsi_min

// ═══════════════════════════════════════════════════════
//         CURRENT TF STOCHASTIC
// ═══════════════════════════════════════════════════════

curr_stoch_k = ta.sma(ta.stoch(close, high, low, stoch_k_len), stoch_k_smooth)
curr_stoch_d = ta.sma(curr_stoch_k, stoch_d_smooth)

cond_curr_stoch_cross = ta.crossover(curr_stoch_k, curr_stoch_d) and curr_stoch_k < stoch_cross_level

// ═══════════════════════════════════════════════════════
//         BULL CANDLE FILTER
// ═══════════════════════════════════════════════════════

is_bull_candle = close > open

// ═══════════════════════════════════════════════════════
//              COMBINED BUY SIGNAL
// ═══════════════════════════════════════════════════════

buy_signal = cond_htf_macd_slope    and
             cond_htf_rsi           and
             cond_htf_bb_upper_half and
             cond_curr_rsi          and
             cond_curr_stoch_cross  and
             is_bull_candle

// ═══════════════════════════════════════════════════════
//              VISUALS ON CHART
// ═══════════════════════════════════════════════════════

plotshape(
     show_signals and buy_signal,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     size=size.normal,
     text="BUY")

if show_labels and buy_signal
    label.new(
         bar_index, low,
         text="BUY SIGNAL\n" +
              "HTF MACD ✓ | HTF RSI: " + str.tostring(math.round(htf_rsi, 1)) +
              "\nHTF BB ✓ | RSI: "      + str.tostring(math.round(curr_rsi, 1)) +
              "\nStoch %K: "            + str.tostring(math.round(curr_stoch_k, 1)) +
              "\nBull Candle ✓",
         style=label.style_label_up,
         color=color.new(color.lime, 10),
         textcolor=color.black,
         yloc=yloc.belowbar,
         size=size.small)

bgcolor(buy_signal ? color.new(color.lime, 88) : na, title="Buy Signal Background")

// ═══════════════════════════════════════════════════════
//    CONDITION STATUS TABLE (bottom-right corner)
// ═══════════════════════════════════════════════════════

higher_tf_label = is_daily_tf ? "Monthly" : "Weekly"

var table status_table = table.new(
     position.bottom_right, 2, 8,
     bgcolor=color.new(color.black, 60),
     border_color=color.gray,
     border_width=1,
     frame_color=color.gray,
     frame_width=1)

if barstate.islast
    table.cell(status_table, 0, 0, "CONDITION [HTF: " + higher_tf_label + "]",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20))
    table.cell(status_table, 1, 0, "STATUS",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20))

    table.cell(status_table, 0, 1, higher_tf_label + " MACD Slope ↑",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 1, cond_htf_macd_slope ? "✓ YES" : "✗ NO",
         text_color=cond_htf_macd_slope ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 2, higher_tf_label + " RSI ≥ 45 (" + str.tostring(math.round(htf_rsi, 1)) + ")",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 2, cond_htf_rsi ? "✓ YES" : "✗ NO",
         text_color=cond_htf_rsi ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 3, higher_tf_label + " BB Upper Half",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 3, cond_htf_bb_upper_half ? "✓ YES" : "✗ NO",
         text_color=cond_htf_bb_upper_half ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 4, "RSI ≥ 35 (" + str.tostring(math.round(curr_rsi, 1)) + ")",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 4, cond_curr_rsi ? "✓ YES" : "✗ NO",
         text_color=cond_curr_rsi ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 5, "Stoch %K x %D (below 40)",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 5, cond_curr_stoch_cross ? "✓ YES" : "✗ NO",
         text_color=cond_curr_stoch_cross ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 6, "Bull Candle (Close > Open)",
         text_color=color.silver, text_size=size.small)
    table.cell(status_table, 1, 6, is_bull_candle ? "✓ YES" : "✗ NO",
         text_color=is_bull_candle ? color.lime : color.red, text_size=size.small)

    table.cell(status_table, 0, 7, "⚡ BUY SIGNAL",
         text_color=color.white, text_size=size.small,
         bgcolor=buy_signal ? color.new(color.lime, 30) : color.new(color.red, 30))
    table.cell(status_table, 1, 7, buy_signal ? "🟢 ACTIVE" : "🔴 WAITING",
         text_color=buy_signal ? color.lime : color.red, text_size=size.small,
         bgcolor=buy_signal ? color.new(color.lime, 30) : color.new(color.red, 30))

// ═══════════════════════════════════════════════════════
//              ALERT CONDITIONS
// ═══════════════════════════════════════════════════════

alertcondition(
     buy_signal,
     title="🟢 BUY Signal - All Conditions Met",
     message="BUY SIGNAL on {{ticker}} at {{close}}\nTimeframe: {{interval}}\nTime: {{time}}\n✓ Higher TF MACD slope up\n✓ Higher TF RSI ≥ 45\n✓ Price in upper BB half\n✓ Current TF RSI ≥ 35\n✓ Stoch %K crossed above %D below 40\n✓ Bull Candle")
````
