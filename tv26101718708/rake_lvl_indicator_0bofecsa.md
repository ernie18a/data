# RAKE LVL Indicator

- url: https://www.tradingview.com/script/0BofEcSa-RAKE-LVL-Indicator/
- type: indicator
- pine_id: PUB;5aa4117cb6ce48c7b0792eeaf821c197
- version: 2.0

## Description

RAKE LVL Indicator — How to Read Your Chart
The Lines
The green line is the Opening Print — the first price NQ traded at 9:30 AM. This is the most important level of the day. Everything revolves around it.
The yellow dashed lines are your hourly levels — drawn automatically at the open of every candle where the hourly chart changed color. These are the destinations price moves toward and the reaction points to watch when price arrives. They disappear automatically when price gets an hourly close through them.
The Dashboard (top right)
Read it top to bottom before doing anything:

5min / 15min / 1 Hour rows — green background means that timeframe is bullish, red means bearish. You want all three the same color before considering a trade.
MTF ALIGN — the most important row. "✅ ALL LONG" or "✅ ALL SHORT" means all three timeframes agree and the system is armed. Anything else means wait.
Near Level — shows ⚡ when price is within range of a level or the OP. This is when to pay close attention.
Gap Signal — tells you at the open whether it's a Gap Over Red (bullish day bias) or Gap Under Green (bearish day bias).

The Shapes on the Chart

Green triangle + "BUY" — a buy setup triggered at a level with all 3 timeframes bullish
Red triangle + "SELL" — a sell setup triggered at a level with all 3 timeframes bearish
Green label + "OPP" — Jake's highest quality setup: buy setup triggered right at the Opening Print with full MTF alignment

The Simple Workflow

Market opens at 9:30 — green OP line appears, check the Gap Signal row
Watch the MTF ALIGN row — wait for "✅ ALL LONG" or "✅ ALL SHORT"
Watch for "⚡ AT OP" or "⚡ AT LEVEL" in the Near Level row
When a BUY or SELL triangle appears — that's the mechanical trigger
Before entering: does the setup match your pre-market plan? Is the R:R at least 2.5:1?

The alerts do the watching for you — you don't need to stare at the screen. Alert 6 (OPP A+) is the one to prioritize above all others.

## Source Code

````pine
// Jake Ricci / RakeTrades Level System Indicator
// Based on Mastermind 15.0 teaching
// Pine Script v6
//
// What this does:
// 1. Marks the Opening Print (green line) at 9:30 AM market open
// 2. Auto-detects hourly candle color changes and marks the OPEN of the change candle (the level)
// 3. Deletes levels when price gets an hourly candle close through them
// 4. Multi-timeframe confirmation: 5-min setup + 15-min trend + hourly trend must ALL agree
// 5. Alerts for: OPP, buy/sell at levels, gap signals — only when all TFs are aligned
//
// HOW TO USE:
// - Apply to NQ1!, ES1!, RTY1!, or YM1! on the 5-MINUTE chart
// - Chart settings: uncheck "Extended trading hours", check "Start aggregation at market open"
// - Set alerts via the Alert menu

//@version=6
indicator(title="Level System", shorttitle="Sams Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show_op          = input.bool(true,  "Show Opening Print",               group="Opening Print")
op_color         = input.color(color.new(#00FF88, 0), "Opening Print Color", group="Opening Print")
op_width         = input.int(2, "Line Width", minval=1, maxval=4,        group="Opening Print")

show_levels      = input.bool(true,  "Show Hourly Levels",               group="Levels")
level_color      = input.color(color.new(#FFD700, 60), "Level Color",    group="Levels")
level_width      = input.int(1, "Line Width", minval=1, maxval=4,        group="Levels")

show_gap_signals = input.bool(true,  "Show Gap Over Red / Gap Under Green", group="Gap Signals")

alert_proximity  = input.float(0.10, "Proximity to Level (% of price)", minval=0.01, maxval=0.50, step=0.01,
                     group="Alerts",
                     tooltip="Tighter than before (0.10% vs 0.15%). On NQ this is ~15-20 points. Reduces noise.")

show_mtf_filter  = input.bool(true,  "Show MTF Confirmation Status",     group="Multi-Timeframe")
require_mtf      = input.bool(true,  "Require MTF Alignment for Alerts", group="Multi-Timeframe",
                     tooltip="When ON, alerts only fire when 5-min + 15-min + hourly all agree. Jake Rule 4.")

// ─── TIME HELPERS ─────────────────────────────────────────────────────────────
is_regular_session = not na(time("60", "0930-1600"))
is_market_open     = hour == 9 and minute == 30 and is_regular_session

// ─── MULTI-TIMEFRAME DATA ─────────────────────────────────────────────────────
// 5-minute (current chart)
ema20_5m = ta.ema(close, 20)

// 15-minute trend via EMA
ema20_15m = request.security(syminfo.tickerid, "15",
              ta.ema(close, 20), lookahead=barmerge.lookahead_off)
close_15m = request.security(syminfo.tickerid, "15",
              close, lookahead=barmerge.lookahead_off)

// Hourly trend — open/close for color + EMA
[h_open, h_close, h_ema20] = request.security(syminfo.tickerid, "60",
              [open, close, ta.ema(close, 20)], lookahead=barmerge.lookahead_off)
[h_open1, h_close1]        = request.security(syminfo.tickerid, "60",
              [open[1], close[1]], lookahead=barmerge.lookahead_off)

// Daily data for gap signals
[d_open, d_open1, d_close1] = request.security(syminfo.tickerid, "D",
              [open, open[1], close[1]], lookahead=barmerge.lookahead_off)

// ─── TREND BIAS PER TIMEFRAME ─────────────────────────────────────────────────
// Uptrend bias = price above its 20 EMA on that timeframe
bull_5m  = close    > ema20_5m   // 5-min bullish
bear_5m  = close    < ema20_5m   // 5-min bearish

bull_15m = close_15m > ema20_15m // 15-min bullish
bear_15m = close_15m < ema20_15m // 15-min bearish

bull_1h  = h_close  > h_ema20   // hourly bullish
bear_1h  = h_close  < h_ema20   // hourly bearish

// Full MTF alignment
mtf_bull = bull_5m and bull_15m and bull_1h   // all three timeframes agree: up
mtf_bear = bear_5m and bear_15m and bear_1h   // all three timeframes agree: down

// Partial alignment (2 of 3) for informational display
partial_bull = (bull_5m  and bull_15m) or (bull_5m  and bull_1h) or (bull_15m and bull_1h)
partial_bear = (bear_5m  and bear_15m) or (bear_5m  and bear_1h) or (bear_15m and bear_1h)

// ─── OPENING PRINT ────────────────────────────────────────────────────────────
var float opening_print = na
var line  op_line       = na

if is_market_open
    opening_print := open
    if not na(op_line)
        line.delete(op_line)
    if show_op
        op_line := line.new(
             x1    = bar_index,
             y1    = opening_print,
             x2    = bar_index + 1,
             y2    = opening_print,
             color = op_color,
             width = op_width,
             style = line.style_solid,
             extend= extend.right)
        label.new(
             x         = bar_index,
             y         = opening_print,
             text      = "OP  " + str.tostring(opening_print, "#.##"),
             color     = color.new(#00FF88, 20),
             textcolor = color.black,
             style     = label.style_label_right,
             size      = size.small)

// ─── HOURLY LEVEL DETECTION ───────────────────────────────────────────────────
h_was_green = h_close1 > h_open1
h_was_red   = h_close1 < h_open1
h_now_green = h_close  > h_open
h_now_red   = h_close  < h_open

hourly_color_change = (h_was_green and h_now_red) or (h_was_red and h_now_green)

// ─── LEVEL STORAGE & MANAGEMENT ───────────────────────────────────────────────
var float[] level_prices = array.new_float(0)
var line[]  level_lines  = array.new_line(0)

if hourly_color_change and is_regular_session and show_levels
    lev    = h_open
    is_dup = false
    n      = array.size(level_prices)
    if n > 0
        for i = 0 to n - 1
            if math.abs(array.get(level_prices, i) - lev) / lev * 100 < 0.05
                is_dup := true
                break
    if not is_dup
        array.push(level_prices, lev)
        new_line = line.new(
             x1    = bar_index,
             y1    = lev,
             x2    = bar_index + 1,
             y2    = lev,
             color = level_color,
             width = level_width,
             style = line.style_dashed,
             extend= extend.right)
        array.push(level_lines, new_line)
        label.new(
             x         = bar_index,
             y         = lev,
             text      = str.tostring(lev, "#.##"),
             color     = color.new(#FFD700, 40),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.tiny)

// Remove levels where hourly closed through them (Rule 4)
if barstate.isconfirmed
    i = 0
    while i < array.size(level_prices)
        lev          = array.get(level_prices, i)
        closed_above = h_close > lev and h_close1 < lev
        closed_below = h_close < lev and h_close1 > lev
        if closed_above or closed_below
            if i < array.size(level_lines)
                line.delete(array.get(level_lines, i))
                array.remove(level_lines, i)
            array.remove(level_prices, i)
        else
            i += 1

// ─── GAP SIGNALS ──────────────────────────────────────────────────────────────
prev_day_red    = d_close1 < d_open1
prev_day_green  = d_close1 > d_open1
gap_over_red    = prev_day_red   and d_open > d_open1
gap_under_green = prev_day_green and d_open < d_open1

if is_market_open and show_gap_signals
    if gap_over_red
        label.new(
             x         = bar_index,
             y         = low,
             text      = "⬆ GAP OVER RED\nBias: LONG above OP",
             color     = color.new(color.green, 20),
             textcolor = color.white,
             style     = label.style_label_up,
             size      = size.normal)
    if gap_under_green
        label.new(
             x         = bar_index,
             y         = high,
             text      = "⬇ GAP UNDER GREEN\nBias: SHORT below OP",
             color     = color.new(color.red, 20),
             textcolor = color.white,
             style     = label.style_label_down,
             size      = size.normal)

// ─── PROXIMITY CHECK ──────────────────────────────────────────────────────────
near_any_level = false
n_lev = array.size(level_prices)
if n_lev > 0
    for i = 0 to n_lev - 1
        lev = array.get(level_prices, i)
        if math.abs(close - lev) <= lev * alert_proximity / 100
            near_any_level := true
            break

near_op = not na(opening_print) and
          math.abs(close - opening_print) <= opening_print * alert_proximity / 100

near_reference = near_any_level or near_op

// ─── BUY / SELL SETUP DETECTION (5-MIN CHART) ────────────────────────────────
// Buy setup:  current bar breaks above previous bar's high (with uptrend bias on 5m)
// Sell setup: current bar breaks below previous bar's low  (with downtrend bias on 5m)
buy_setup_raw  = ta.crossover(high,  high[1]) and bull_5m
sell_setup_raw = ta.crossunder(low,  low[1])  and bear_5m

// With full MTF confirmation (Rule 4 — all three TFs agree)
buy_setup_mtf  = buy_setup_raw  and mtf_bull
sell_setup_mtf = sell_setup_raw and mtf_bear

// At a level or OP
buy_at_level_raw  = buy_setup_raw  and near_reference
sell_at_level_raw = sell_setup_raw and near_reference

buy_at_level_mtf  = buy_setup_mtf  and near_reference
sell_at_level_mtf = sell_setup_mtf and near_reference

// OPP: buy setup at OP specifically with full MTF alignment
opp_setup_mtf = buy_at_level_mtf and near_op

// Use MTF-filtered signals if require_mtf is ON, raw if OFF
buy_signal  = require_mtf ? buy_at_level_mtf  : buy_at_level_raw
sell_signal = require_mtf ? sell_at_level_mtf : sell_at_level_raw
opp_signal  = require_mtf ? opp_setup_mtf     : (buy_at_level_raw and near_op)

// ─── CHART SHAPES ─────────────────────────────────────────────────────────────
plotshape(buy_signal,  title="Buy Setup at Level",
          style=shape.triangleup,   location=location.belowbar,
          color=color.new(#00FF88, 0), size=size.small, text="BUY")

plotshape(sell_signal, title="Sell Setup at Level",
          style=shape.triangledown, location=location.abovebar,
          color=color.new(#FF4444, 0), size=size.small, text="SELL")

plotshape(opp_signal,  title="OPP Setup",
          style=shape.labelup,      location=location.belowbar,
          color=color.new(#00FF88, 0), size=size.normal, text="OPP")

// Dim shapes when only partial alignment (informational — no alert)
plotshape(buy_setup_raw and near_reference and not buy_signal and not require_mtf,
          title="Buy (Partial MTF)", style=shape.triangleup, location=location.belowbar,
          color=color.new(#00FF88, 70), size=size.tiny, text="b")

plotshape(sell_setup_raw and near_reference and not sell_signal and not require_mtf,
          title="Sell (Partial MTF)", style=shape.triangledown, location=location.abovebar,
          color=color.new(#FF4444, 70), size=size.tiny, text="s")

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(is_market_open and not na(opening_print),
     title="1. Opening Print Marked",
     message="Opening Print marked — OP active. Watch for OPP setup.")

alertcondition(near_op and is_regular_session and mtf_bull,
     title="2. Price at Opening Print — MTF Bullish (OPP Watch)",
     message="⬆ OPP WATCH: Price at Opening Print. 5min + 15min + Hourly all bullish. Look for buy setup trigger.")

alertcondition(near_op and is_regular_session and mtf_bear,
     title="3. Price at Opening Print — MTF Bearish",
     message="⬇ SHORT WATCH: Price at Opening Print. 5min + 15min + Hourly all bearish. Look for sell setup trigger.")

alertcondition(buy_signal,
     title="4. BUY Setup — MTF Confirmed",
     message="✅ BUY SIGNAL: 5min buy setup triggered at a level. 15min + Hourly agree. Check your plan before entering.")

alertcondition(sell_signal,
     title="5. SELL Setup — MTF Confirmed",
     message="✅ SELL SIGNAL: 5min sell setup triggered at a level. 15min + Hourly agree. Check your plan before entering.")

alertcondition(opp_signal,
     title="6. OPP Buy Setup — A+ Quality",
     message="⭐ OPP A+ SETUP: Buy setup at Opening Print. All 3 timeframes bullish. Jake's highest quality setup.")

alertcondition(gap_over_red and is_market_open,
     title="7. Gap Over Red — Bullish Day",
     message="⬆ GAP OVER RED: Bias is LONG today. Watch for OP to hold → longs up to next level.")

alertcondition(gap_under_green and is_market_open,
     title="8. Gap Under Green — Bearish Day",
     message="⬇ GAP UNDER GREEN: Bias is SHORT today. Watch for OP to reject → shorts down to next level.")

alertcondition(mtf_bull and not mtf_bull[1],
     title="9. All 3 Timeframes Flipped Bullish",
     message="📈 MTF SHIFT: 5min + 15min + Hourly just all aligned bullish. Trend may be shifting up.")

alertcondition(mtf_bear and not mtf_bear[1],
     title="10. All 3 Timeframes Flipped Bearish",
     message="📉 MTF SHIFT: 5min + 15min + Hourly just all aligned bearish. Trend may be shifting down.")

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
// Cell background colors
var color BG_DARK    = color.new(#0D0D0D, 0)   // near-black cell bg
var color BG_HEADER  = color.new(#1A1A2E, 0)   // dark navy header
var color BG_BULL    = color.new(#003300, 0)   // dark green bg for bull rows
var color BG_BEAR    = color.new(#330000, 0)   // dark red bg for bear rows
var color BG_NEUTRAL = color.new(#1A1A1A, 0)   // dark grey for neutral

var color TXT_WHITE  = color.new(#FFFFFF, 0)
var color TXT_GOLD   = color.new(#FFD700, 0)
var color TXT_GREEN  = color.new(#00FF88, 0)
var color TXT_RED    = color.new(#FF4444, 0)
var color TXT_GRAY   = color.new(#888888, 0)

var table dash = table.new(position.top_right, 2, 9,
     bgcolor      = color.new(#0D0D0D, 0),
     border_color = color.new(#FFD700,  0), border_width = 1,
     frame_color  = color.new(#FFD700,  0), frame_width  = 2)

if barstate.islast and show_mtf_filter

    // Header row
    table.cell(dash, 0, 0, "RAKE LVL",  text_color=TXT_GOLD,  text_size=size.small, bgcolor=BG_HEADER)
    table.cell(dash, 1, 0, "STATUS",    text_color=TXT_GOLD,  text_size=size.small, bgcolor=BG_HEADER)

    // Opening print
    op_val = na(opening_print) ? "Waiting..." : str.tostring(opening_print, "#.##")
    table.cell(dash, 0, 1, "Open Print", text_color=TXT_WHITE, text_size=size.tiny, bgcolor=BG_DARK)
    table.cell(dash, 1, 1, op_val,       text_color=TXT_GREEN, text_size=size.tiny, bgcolor=BG_DARK)

    // Active levels
    table.cell(dash, 0, 2, "Levels",    text_color=TXT_WHITE, text_size=size.tiny, bgcolor=BG_DARK)
    table.cell(dash, 1, 2, str.tostring(array.size(level_prices)),
         text_color=TXT_GOLD, text_size=size.tiny, bgcolor=BG_DARK)

    // 5-min trend
    bg_5m = bull_5m ? BG_BULL : bear_5m ? BG_BEAR : BG_NEUTRAL
    tc_5m = bull_5m ? TXT_GREEN : bear_5m ? TXT_RED : TXT_GRAY
    table.cell(dash, 0, 3, "5min",      text_color=TXT_WHITE, text_size=size.tiny, bgcolor=bg_5m)
    table.cell(dash, 1, 3, bull_5m ? "▲ BULL" : bear_5m ? "▼ BEAR" : "–",
         text_color=tc_5m, text_size=size.tiny, bgcolor=bg_5m)

    // 15-min trend
    bg_15m = bull_15m ? BG_BULL : bear_15m ? BG_BEAR : BG_NEUTRAL
    tc_15m = bull_15m ? TXT_GREEN : bear_15m ? TXT_RED : TXT_GRAY
    table.cell(dash, 0, 4, "15min",     text_color=TXT_WHITE, text_size=size.tiny, bgcolor=bg_15m)
    table.cell(dash, 1, 4, bull_15m ? "▲ BULL" : bear_15m ? "▼ BEAR" : "–",
         text_color=tc_15m, text_size=size.tiny, bgcolor=bg_15m)

    // Hourly trend
    bg_1h = bull_1h ? BG_BULL : bear_1h ? BG_BEAR : BG_NEUTRAL
    tc_1h = bull_1h ? TXT_GREEN : bear_1h ? TXT_RED : TXT_GRAY
    table.cell(dash, 0, 5, "1 Hour",    text_color=TXT_WHITE, text_size=size.tiny, bgcolor=bg_1h)
    table.cell(dash, 1, 5, bull_1h ? "▲ BULL" : bear_1h ? "▼ BEAR" : "–",
         text_color=tc_1h, text_size=size.tiny, bgcolor=bg_1h)

    // MTF alignment — most important row, biggest visual impact
    mtf_txt   = mtf_bull ? "✅ ALL LONG" : mtf_bear ? "✅ ALL SHORT" : partial_bull ? "~ PARTIAL ▲" : partial_bear ? "~ PARTIAL ▼" : "✗ NO ALIGN"
    mtf_tc    = mtf_bull ? TXT_GREEN : mtf_bear ? TXT_RED : TXT_GOLD
    mtf_bg    = mtf_bull ? BG_BULL   : mtf_bear ? BG_BEAR : BG_NEUTRAL
    table.cell(dash, 0, 6, "MTF ALIGN", text_color=TXT_GOLD,  text_size=size.small, bgcolor=mtf_bg)
    table.cell(dash, 1, 6, mtf_txt,     text_color=mtf_tc,    text_size=size.small, bgcolor=mtf_bg)

    // Near level
    near_txt = near_op ? "⚡ AT OP" : near_any_level ? "⚡ AT LEVEL" : "–"
    near_tc  = near_reference ? TXT_GOLD : TXT_GRAY
    near_bg  = near_reference ? color.new(#2A2000, 0) : BG_DARK
    table.cell(dash, 0, 7, "Near Level", text_color=TXT_WHITE, text_size=size.tiny, bgcolor=near_bg)
    table.cell(dash, 1, 7, near_txt,     text_color=near_tc,   text_size=size.tiny, bgcolor=near_bg)

    // Gap signal
    gap_txt = gap_over_red ? "⬆ OVER RED" : gap_under_green ? "⬇ UNDER GRN" : "–"
    gap_tc  = gap_over_red ? TXT_GREEN : gap_under_green ? TXT_RED : TXT_GRAY
    gap_bg  = gap_over_red ? BG_BULL   : gap_under_green ? BG_BEAR : BG_DARK
    table.cell(dash, 0, 8, "Gap Signal", text_color=TXT_WHITE, text_size=size.tiny, bgcolor=gap_bg)
    table.cell(dash, 1, 8, gap_txt,      text_color=gap_tc,    text_size=size.tiny, bgcolor=gap_bg)
````
